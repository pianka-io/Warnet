from flask import Flask, request, jsonify
import subprocess
import re

app = Flask(__name__)

CONFIG_PATH = "/opt/init6/init6.conf"


@app.route('/update-location', methods=['POST'])
def update_location():
    data = request.get_json()
    if not data or "location" not in data:
        return jsonify({"error": "Missing 'location' in request"}), 400

    location = data["location"]

    try:
        with open(CONFIG_PATH, "r") as file:
            config = file.read()

        updated_config = re.sub(r"<LOCATION>", location, config)

        with open(CONFIG_PATH, "w") as file:
            file.write(updated_config)

        try:
            subprocess.run(["/usr/bin/systemctl", "restart", "init6"], check=True)
        except subprocess.CalledProcessError as e:
            return jsonify({"error": f"Failed to restart init6: {str(e)}"}), 500

        # subprocess.run(["/usr/bin/systemctl", "restart", "nftables"], check=True)
        subprocess.run(["reboot"], check=True)

        return jsonify({"message": "Location updated successfully, init6 restarted, and nftables restored", "location": location})

    except subprocess.CalledProcessError as e:
        return jsonify({"error": f"Failed to modify nftables: {str(e)}"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    subprocess.run(["/usr/sbin/nft", "flush", "ruleset"], check=True)
    app.run(host='0.0.0.0', port=8080)
