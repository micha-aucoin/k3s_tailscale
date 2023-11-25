#!/usr/bin/env python3

import argparse
import json
import os

import requests
from requests.auth import HTTPBasicAuth


def get_access_token(client_id: str, client_secret: str) -> str:
    token_url = "https://api.tailscale.com/api/v2/oauth/token"
    auth = HTTPBasicAuth(client_id, client_secret)
    data = {'grant_type': 'client_credentials'}

    response = requests.post(token_url, auth=auth, data=data)
    response.raise_for_status()

    return response.json()['access_token']


def list_tailnet_devices(access_token: str, tailnet: str,) -> dict | None:
    try:
        api_url = f"https://api.tailscale.com/api/v2/tailnet/{tailnet}/devices"
        headers = {'Authorization': f'Bearer {access_token}'}

        response = requests.get(api_url, headers=headers)
        response.raise_for_status()

        return response.json()
    
    except requests.HTTPError as e:
        print(f"Error accessing Tailscale API: {e}")
        print(f"Response content: {response.content}")

    except Exception as e:
        print(f"An unexpected error occurred: {e}")

def get_tailscale_addresses(devices: dict, tag: str) -> list | None:
    addresses = []
    for device in devices['devices']:
        if 'tags' in device and device['tags'] == [f'tag:{tag}']:
            addresses.append(device['addresses'][0])
    if addresses == []:
        return ['none']
    else:
        return addresses

class ExampleInventory(object):

    def __init__(self):
        self.inventory = {}
        self.read_cli_args()

        # Called with `--list`.
        if self.args.list:
            self.inventory = self.example_inventory()
        # Called with `--host [hostname]`.
        elif self.args.host:
            # Not implemented, since we return _meta info `--list`.
            self.inventory = self.empty_inventory()
        # If no groups or vars are present, return empty inventory.
        else:
            self.inventory = self.empty_inventory()

        print(json.dumps(self.inventory))

    # Example inventory for testing.
    def example_inventory(self):
        return {
            'tailscale_servers': {
                'hosts': servers,
                'vars': {}
            }
        }

    # Empty inventory for testing.
    def empty_inventory(self):
        return {'_meta': {'hostvars': {}}}

    # Read the command line args passed to the script.
    def read_cli_args(self):
        parser = argparse.ArgumentParser()
        parser.add_argument('--list', action = 'store_true')
        parser.add_argument('--host', action = 'store')
        self.args = parser.parse_args()

# Get the inventory.
client_id = os.getenv("OAUTH_CLIENT_ID")
client_secret = os.getenv("OAUTH_CLIENT_SECRET")
tailnet_name = 'example.com' # tailnet name == organization name -> https://login.tailscale.com/admin/settings/general
# vpn_auth = 'name=tailscale,joinKey=' + os.getenv("VPN_AUTH")

access_token = get_access_token(client_id, client_secret)
devices = list_tailnet_devices(access_token, tailnet_name)

servers = get_tailscale_addresses(devices=devices, tag='k3s-server',)

ExampleInventory()