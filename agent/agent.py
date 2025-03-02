import subprocess
import re
import logging
from flask import Flask, request, jsonify

app = Flask(__name__)

CONFIG_PATH = "/opt/init6/init6.conf"
NFTABLES_BACKUP_PATH = "/etc/sysconfig/nftables.conf"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    force=True
)

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


if __name__ == '__main__':
    try:
        logging.info("Flushing nftables ruleset on startup...")
        subprocess.run(["sudo", "/usr/sbin/nft", "flush", "ruleset"], check=True)
    except subprocess.CalledProcessError as e:
        logging.error(f"Failed to flush nftables rules: {e.stderr}")

    logging.info("Starting Flask server on port 8080...")
    app.run(host='0.0.0.0', port=8080)
