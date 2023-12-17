import argparse
import json
import os
import requests

FILE_PATH = os.path.expanduser(os.path.expandvars('azure-k8s-cluster-telemetry.json'))

def __publish_put(conn:str, payload:list):
    headers = {
        "type": "json",
        "dbms": "openhorizon",
        "table": "host_list",
        "mode": "streaming",
        "Content-Type": "text/plain",
        "User-Agent": "AnyLog/1.23"
    }

    try:
        r = requests.put(url=f"http://{conn}", headers=headers, data=json.dumps(payload))
    except Exception as error:
        print(f"Failed to send data (Error; {error})")
    else:
        if int(r.status_code) != 200:
            print(r.status_code)


def __publish_post(conn:str, payloads:list):
    headers = {
        'command': 'data',
        'topic': "aks",
        'User-Agent': 'AnyLog/1.23',
        'Content-Type': 'text/plain'
    }

    try:
        r = requests.post(url=f"http://{conn}", headers=headers, data=json.dumps(payloads))
    except Exception as error:
        print(f"Failed to send data (Error; {error})")
    else:
        if int(r.status_code) != 200:
            print(r.status_code)


def __get_data():
    host_list = []
    kubearmor = []
    with open(FILE_PATH, 'r') as f:
        for line in f.readlines():
            try:
                line = json.loads(line)
            except json.decoder.JSONDecodeError:
                pass
            else:
                if sorted(list(line.keys())) == sorted(list({"ClusterName":"default","HostName":"aks-bahnodepool-23812902-vmss000001","PPID":0,"UID":0}.keys())) and  line not in host_list:
                    host_list.append(line)
                elif line != "":
                    kubearmor.append(line)

    return host_list, kubearmor



def main():
    parse = argparse.ArgumentParser()
    parse.add_argument("--conn", type=str, default="170.187.154.190:32149", help="REST connection info")
    args = parse.parse_args()
    host_list, kubearmor = __get_data()
    __publish_put(conn=args.conn, payload=host_list)
    __publish_post(conn=args.conn, payloads=kubearmor)



if __name__ == '__main__':
    main()

