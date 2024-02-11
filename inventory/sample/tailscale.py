#!/usr/bin/env python3

import argparse
import json
import os
import sys

import requests
from requests.auth import HTTPBasicAuth


class TailscaleManager:
    def __init__(self, client_id: str, client_secret: str, tailnet: str):
        # Tailscale credentials
        self.client_id = client_id
        self.client_secret = client_secret
        self.tailnet = tailnet
        # Tailscale API
        self.api_endpoint = "https://api.tailscale.com/api/v2"
        self.access_token = self.get_access_token()
        self.headers = {
            "Authorization": f"Bearer {self.access_token}",
            "Content-type": "application/json",
        }
        # https://github.com/tailscale/tailscale/blob/main/api.md

    def _url_builder(self, path: str) -> str:
        if path.startswith("/"):
            path = path[1:]
        return f"{self.api_endpoint}/{path}"

    def get_access_token(self) -> str:
        token_url = self._url_builder("oauth/token")
        auth = HTTPBasicAuth(self.client_id, self.client_secret)
        data = {"grant_type": "client_credentials"}

        response = requests.post(token_url, auth=auth, data=data)
        response.raise_for_status()
        return response.json()["access_token"]

    def send(self, url: str, method: str = "GET", params: dict = None) -> dict | None:
        url = self._url_builder(url)
        try:
            if method == "GET":
                response = requests.get(url, headers=self.headers, params=params)
                response.raise_for_status()
                json_resp = response.json()

        except requests.HTTPError as e:
            print(f"Error accessing Tailscale API: {e}")
            print(f"Response content: {response.content}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
        return json_resp

    def all_devices(self):
        resp = self.send(f"tailnet/{self.tailnet}/devices")
        return resp.get("devices", {})

    def show_device(self, device_id: str):
        resp = self.send(f"device/{device_id}")
        return resp
    
    def filter_by_hostname(self, hostname: str) -> list:
        devices = self.all_devices()
        filtered_devices = []
        for device in devices:
            if "hostname" in device and hostname in device["hostname"]:
                filtered_devices.append(device)
        return filtered_devices


class TailscaleInventory(object):
    def __init__(self):
        # Initialize inventory and settings
        self.inventory = {}
        self.data = {}
        self.group_variables = {}

        # Read settings, environment variables, and CLI arguments
        self.read_settings()
        self.read_cli_args()

        # Verify credentials were set
        if not self.client_id or not self.client_secret or not self.tailnet:
            msg = "Missing credentials: Please provide Tailscale client_id, client_secret, and tailnet.\n"
            sys.stderr.write(msg)
            sys.exit(-1)

        # Initialize Tailscale API manager
        self.manager = TailscaleManager(
            client_id=self.client_id,
            client_secret=self.client_secret,
            tailnet=self.tailnet,
        )

        # Manage Tailscale data
        if self.args.host:
            json_data = self.load_tailscale_variables_for_host()
        else:
            self.load_from_tailscale(resource="k3s")
            self.build_inventory()
            json_data = self.inventory

        if self.args.pretty:
            print(json.dumps(json_data, indent=4))
        else:
            print(json.dumps(json_data))

    def read_settings(self):
        """Reads settings from environment variables or a config file"""
        if os.getenv("INVENTORY_CLIENT_ID"):
            self.client_id = os.getenv("INVENTORY_CLIENT_ID")
        if os.getenv("INVENTORY_CLIENT_SECRET"):
            self.client_secret = os.getenv("INVENTORY_CLIENT_SECRET")
        if os.getenv("TAILNET_NAME"):
            self.tailnet = os.getenv("TAILNET_NAME")

    def read_cli_args(self):
        """Read command line arguments"""
        parser = argparse.ArgumentParser(
            description="Produce an Ansible Inventory file based on Tailscale credentials"
        )
        parser.add_argument(
            "--list",
            action="store_true",
            help="List all activate tailscale devices (default: True)",
        )
        parser.add_argument(
            "--host",
            action="store",
            help="Get all Ansible inventory variables about a specific tailscale device",
        )
        parser.add_argument(
            "--pretty",
            "-p",
            action="store_true",
            help="Pretty-print results",
        )
        self.args = parser.parse_args()

        # Make --list default if none of the other commands are specified
        if not self.args.host and not self.args.pretty:
            self.args.list = True

    def load_from_tailscale(self, resource: str = None) -> dict:
        """Get JSON from Tailscale API"""
        if resource == "k3s" or resource is None:
            self.data['k3s'] = self.manager.filter_by_hostname(hostname="k3s")

    def add_inventory_group(self, key):
        """Method to create group dict"""
        host_dict = {"hosts": [], "vars": {}}
        self.inventory[key] = host_dict
        return

    def add_host(self, group, host):
        """Helper method to reduce host duplication"""

        if group not in self.inventory:
            self.add_inventory_group(key=group)

        if host not in self.inventory[group]["hosts"]:
            self.inventory[group]["hosts"].append(host)
        return

    def build_inventory(self):
        """Build Ansible inventory of tailscale hosts"""
        self.inventory = {
            "all": {
                "hosts": [],
                "vars": self.group_variables,
            },
            "_meta": {"hostvars": {}},
        }

        for device in self.data['k3s']:
            host = device["addresses"][0]
            # host = device["hostname"]

            self.inventory["all"]["hosts"].append(host)

            if "k3s" in device["hostname"]:
                group = device["hostname"].split("-")[0]
                self.add_host(group=group, host=host)

            if "server" in device["hostname"]:
                group = device["hostname"].split("-")[1]
                self.add_host(group=group, host=host)

            if "agent" in device["hostname"]:
                group = device["hostname"].split("-")[1]
                self.add_host(group=group, host=host)

            # hostvars
            info = self.ts_namespace(device)
            self.inventory["_meta"]["hostvars"][host] = info

    def load_tailscale_variables_for_host(self):
        """Generate a JSON respone to a --host call"""
        host = int(self.args.host)
        ts_device = self.manager.show_device(host)
        info = self.ts_namespace(ts_device)
        return {"tailscale_device": info}

    @staticmethod
    def ts_namespace(data):
        """Returns a copy of the dictionary with all the keys put in a 'ts_' namespace"""
        info = {}
        for k, v in data.items():
            info["ts_" + k] = v
        return info


if __name__ == "__main__":
    TailscaleInventory()
