import getpass,subprocess,re
from pprint import pprint
from netmiko import (
    ConnectHandler,
    NetmikoTimeoutException,
    NetmikoAuthenticationException,
)

available_sw=[]

#function for checking icmp availability switches in sw_list.txt
def ping_check(sw_name):
	result = subprocess.run(['ping', sw_name], stdout=subprocess.PIPE)
	regexp=r'\[([\d.]+)\]'
	ip_list=re.findall(regexp,str(result))
	if ip_list:
		ip=ip_list[0]
		if result.returncode==0:
			status='OK'
			available_sw.append(sw_name)
		else:
			status='Unavailable by icmp'
	else:
		ip='Not in dns'
		status='Unavailable by icmp'
	print(f'{sw_name:<11} ---   {ip:<11} ---   {status}')

print('\nChecking sw list...\n')
with open('list_sw.txt') as f:
	for sw in f:
		ping_check(sw.strip())

print('\n')


old_password = getpass.getpass(prompt='Enter old pass for by01.admin: ')
old_enable = getpass.getpass(prompt='Enter old enable pass: ')
print()
new_password = getpass.getpass(prompt='Enter new pass for by01.admin: ')
new_password_check = getpass.getpass(prompt='Repeat new pass for by01.admin: ')
print()
new_enable = getpass.getpass(prompt='Enter new enable pass: ')
new_enable_check = getpass.getpass(prompt='Repeat new enable pass: ')


commands=[f'username by01.admin secret {new_password}',
		  f'enable secret {new_enable}']

def change_pass(device, commands):
    try:
        with ConnectHandler(**device) as ssh:
            ssh.enable()
            for command in commands:
                ssh.send_config_set(command)
            ssh.send_command('wr', read_timeout=20)
        print(f'{device["host"]} ---  \x1b[6;30;42m' + 'Success!' + '\x1b[0m')
    except (NetmikoTimeoutException, NetmikoAuthenticationException) as error:
        print(error)


if __name__ == "__main__":
	if new_password==new_password_check and new_enable==new_enable_check:
		print('\nStarting changing passwords...\n')
		for sw in available_sw:
		    device = {
		        "device_type": "cisco_ios",
		        "host": sw,
		        "username": "by01.admin",
		        "password": old_password,
		        "secret": old_enable,
		    }
		    change_pass(device, commands)
	else:
		print('\nDifferent passwords.Try again')


