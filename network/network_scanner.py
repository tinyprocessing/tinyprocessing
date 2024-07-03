import subprocess
import re
import json
import nmap
import threading
import time

def get_ip_neighbors():
    """Get a list of IP addresses and MAC addresses from the neighbor table that are in a specific state."""
    command = "ip neighbor show | grep -E 'STALE|DELAY|REACHABLE'"
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    lines = result.stdout.splitlines()

    ip_mac_pairs = []
    for line in lines:
        ip_match = re.search(r'(\d+\.\d+\.\d+\.\d+)', line)
        mac_match = re.search(r'(([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2})', line)
        if ip_match and mac_match:
            ip_mac_pairs.append((ip_match.group(1), mac_match.group(1)))
    return ip_mac_pairs

def scan_ip(ip, timeout=400):
    """Scan an IP address using nmap and return the result."""
    nm = nmap.PortScanner()
    try:
        nm.scan(ip, arguments='-sV', timeout=timeout)  # -sV to detect service/version info, -p 0-1000 to limit ports
        if ip in nm.all_hosts():
            return nm[ip]
        else:
            return None
    except nmap.PortScannerError as e:
        print(f"Error scanning {ip}: {e}")
        return None

def resolve_device_name(scan_result, mac):
    """Attempt to resolve the device name using nmap scan results and MAC address."""
    vendor = "Unknown Vendor"
    device_name = "Unknown Device"
    
    # Attempt to get the vendor name from the MAC address if present
    if 'mac' in scan_result['addresses']:
        vendor = scan_result['vendor'].get(scan_result['addresses']['mac'], vendor)
    
    # Use hostname or OS info as a device name if available
    if scan_result.hostname():
        device_name = scan_result.hostname()
    elif 'osclass' in scan_result:
        os_info = scan_result['osclass'][0] if scan_result['osclass'] else {}
        os_type = os_info.get('osfamily', 'Unknown')
        device_name = f"{os_type} Device"
    
    return vendor, device_name

def gather_network_info():
    """Gather information about each IP in the network."""
    ip_mac_pairs = get_ip_neighbors()
    network_info = {}

    for ip, mac in ip_mac_pairs:
        print(f"Scanning IP: {ip} with MAC: {mac}")
        scan_result = scan_ip(ip)
        if scan_result:
            vendor, device_name = resolve_device_name(scan_result, mac)
            network_info[ip] = {
                'mac_address': mac,
                'device_name': device_name,
                'vendor': vendor,
                'hostname': scan_result.hostname(),
                'state': scan_result.state(),
                'protocols': []
            }

            for proto in scan_result.all_protocols():
                ports = scan_result[proto].keys()
                proto_info = {
                    'protocol': proto,
                    'ports': []
                }
                for port in ports:
                    port_info = {
                        'port': port,
                        'state': scan_result[proto][port]['state'],
                        'service': scan_result[proto][port]['name'],
                        'version': scan_result[proto][port].get('version', 'unknown')
                    }
                    proto_info['ports'].append(port_info)
                network_info[ip]['protocols'].append(proto_info)
            print(network_info[ip])
        else:
            print(f"No information found for IP: {ip}")
            network_info[ip] = {}

    return network_info

def save_to_json(data, filename):
    """Save the gathered network information to a JSON file."""
    with open(filename, 'w') as f:
        json.dump(data, f, indent=4)

def main():
    network_info = gather_network_info()
    save_to_json(network_info, 'network_info.json')
    print("Network information saved to network_info.json")

if __name__ == "__main__":
    main()
