import time
from datetime import datetime
from colorama import *
import requests
from requests.sessions import session

print(Fore.RED + '''
████████╗██╗██╗  ██╗████████╗ ██████╗ ██╗  ██╗   ██████╗  █████╗ ███╗   ██╗
╚══██╔══╝██║██║ ██╔╝╚══██╔══╝██╔═══██╗██║ ██╔╝   ██╔══██╗██╔══██╗████╗  ██║
   ██║   ██║█████╔╝    ██║   ██║   ██║█████╔╝    ██████╔╝███████║██╔██╗ ██║
   ██║   ██║██╔═██╗    ██║   ██║   ██║██╔═██╗    ██╔══██╗██╔══██║██║╚██╗██║
   ██║   ██║██║  ██╗   ██║   ╚██████╔╝██║  ██╗██╗██████╔╝██║  ██║██║ ╚████║
   ╚═╝   ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
                                         GitHub: LeetIDA                                  
''')

tiktok_url = input("Request Link: ")

while True:
    with open("proxy.txt", "r") as file:
        proxies = file.read().splitlines()

    for proxy in proxies:
        try:
            now = datetime.now()
            current_time = now.strftime("%H:%M:%S")

            req = session().post(tiktok_url, proxies={'http': f'http://{proxy}', 'https': f'http://{proxy}'})
            print(Fore.RED + f'[{current_time}]' + Fore.GREEN + f' Proxy: {proxy} Report Sent')
        except:
            print(Fore.RED + 'Something went wrong. It may not be working properly.')
            input('Press Enter to close the program')
            exit()

        # Add a delay between requests (e.g., 1 second)
        time.sleep(1)

