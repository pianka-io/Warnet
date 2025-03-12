import threading
import logging
import subprocess
import re
import asyncio
from flask import Flask, request, jsonify

from warnet import send_message, run_discord_bot, bot

app = Flask(__name__)

CONFIG_PATH = "/opt/init6/init6.conf"
NFTABLES_BACKUP_PATH = "/etc/sysconfig/nftables.conf"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    force=True
)

# Store the Discord bot event loop globally
discord_loop = None


@app.route('/d2_activity', methods=['POST'])
def d2_activity():
    data = request.get_json()
    if not data or "message" not in data:
        logging.error("Received request with missing 'message'")
        return jsonify({"error": "Missing 'message' in request"}), 400

    message = data["message"]

    # Ensure the coroutine runs in the Discord bot's event loop
    future = asyncio.run_coroutine_threadsafe(send_message(message), discord_loop)
    future.result()  # Wait for completion

    return jsonify({"status": "Message processing started"}), 200


@app.route('/update-location', methods=['POST'])
def update_location():
    data = request.get_json()
    if not data or "location" not in data:
        logging.error("Received request with missing 'location'")
        return jsonify({"error": "Missing 'location' in request"}), 400

    location = data["location"]
    ip_address = data["ip_address"]
    logging.info(f"Received request to update location: {location}")

    try:
        logging.info(f"Reading config file: {CONFIG_PATH}")
        with open(CONFIG_PATH, "r") as file:
            config = file.read()

        updated_config = re.sub(r"<LOCATION>", location, config)
        updated_config = re.sub(r"<IP_ADDRESS>", ip_address, updated_config)

        logging.info(f"Writing updated location to {CONFIG_PATH}")
        with open(CONFIG_PATH, "w") as file:
            file.write(updated_config)

        logging.info(f"Restoring nftables rules from {NFTABLES_BACKUP_PATH}")
        subprocess.run(["sudo", "/usr/sbin/nft", "-f", NFTABLES_BACKUP_PATH], check=True)

        logging.info("Rebooting system now...")
        subprocess.run(["sudo", "reboot"], check=True)

        return jsonify({"message": "Location updated successfully, init6 restarted, and nftables restored", "location": location})

    except subprocess.CalledProcessError as e:
        logging.error(f"Command failed: {e.cmd}, Return Code: {e.returncode}, Error: {e.stderr}")
        return jsonify({"error": f"Command failed: {e.cmd}, Error: {e.stderr}"}), 500

    except Exception as e:
        logging.error(f"Unexpected error: {str(e)}")
        return jsonify({"error": str(e)}), 500


def run_flask():
    logging.info("Starting Flask server on port 8889...")
    app.run(host='0.0.0.0', port=8889, use_reloader=False)


if __name__ == '__main__':
    with open(CONFIG_PATH, "r") as file:
        config = file.read()

    if "<LOCATION>" in config:
        try:
            subprocess.run(["sudo", "/usr/sbin/nft", "flush", "ruleset"], check=True)
        except subprocess.CalledProcessError as e:
            logging.error(f"Failed to flush nftables rules: {e}")

    flask_thread = threading.Thread(target=run_flask, daemon=True)
    flask_thread.start()

    discord_loop = asyncio.get_event_loop()
    discord_loop.run_until_complete(run_discord_bot())
