# ssh-short

The aim of ssh-short is reduce the amount you have to type when ssh-ing into common hosts, 
from something like:
```
ssh -i /path/to/my/key.pem username@10.55.2.16
```
to:
```
sshort 16
```
or even an alias if you set one:
```
sshort fav
```

The command `sshort` was chosen because it's easy and quick to type, 
even if it's not the most descriptive name (suggestions welcome!)

### Config

If you often ssh into a set of hosts that have similar IPs with a common username (such as Amazon EC2 instances),  
then ssh-short can use a combination of config and map files to reduce the repetitive typing when ssh-ing into these hosts.

You first create a config file (`~/.ssh-short/config.yml`) like the following:
```
---
:keys_dir: '~/my/ssh/keys'
:ip_mask:  10.55.2.0
:default_user: my-user
```

##### `keys_dir`

This is where ssh-short will look for your ssh keys, it assumes that they're all in here

##### `ip_mask`

The mask provides a way of avoiding having to type the full IP every time.

If all your IPs start with `10.55.2` for example, then set the mask to `10.55.2.0`, 
now you only have to provide the last segment and ssh-short will add what's missing 
using the sections from the mask.
Any sections you pass in overwrite the mask, so you can still connect to IPs that 
are completely different from the mask

Here's an example of masks, input and outputs

| Mask      | Input        | Result       |
|-----------|--------------|--------------|
| 10.55.2.0 |  16          | 10.55.2.16   |
| 10.55.2.0 |  2.16        | 10.55.2.16   |
| 10.55.2.0 |  55.2.16     | 10.55.2.16   |
| 10.55.2.0 |  10.55.2.16  | 10.55.2.16   |
| 10.55.2.0 |  192.168.1.2 | 192.168.1.2  |
| 10.60.0.0 |  16          | 10.60.0.16   |
| 10.60.0.0 |  22.2        | 10.60.22.2   |
| 10.60.0.0 |  222.22.2    | 10.222.22.2  |

##### `default_user`

Hopefully this is self explanatory, it's the username that will be used 
to connect to the host if no user is provided. 

You can override the user for a node, see args section below

### Keys

When you connect to a host for the first time with ssh-short, it will scan your `keys_dir`
and present you with a list of numbered keys:

**Update:** As of version 0.2.0 your default SSH Key (`id_rsa`) can now be used and will be presented as option `0`

```
user@localhost $ sshort 16
Select a key:
0) id_rsa
1) Dev.pem
2) Test.pem
3) Admin.pem
```

Simply type the number of the key and press enter. ssh-short will connect you via `ssh`, 
and it will also remember your choice in `~/.ssh-short/nodemap.yml` so the next time you connect 
it will look for the key name in the nodemap file and use that automatically:
```
user@localhost $ sshort 16
Connecting as my-user to 10.55.2.16 using Test.pem
...
```

It stores the name of the file (e.g. `Test.pem`), not the number you select, or the full path to the key. 
This way if you add keys or change your keys directory it doesn't matter, 
as long as the file name stays the same

If you chose the wrong key or need to change the key, see args section below

### Args

#### `-u`
Specify a user. This will be used instead of the defualt user. The user is saved in the nodemap so you only have to set it once. If the user does change, use this command to update the nodemap:

```
user@localhost $ sshort 16
Connecting as my-user to 10.55.2.16 using Test.pem
...
user@localhost $ sshort 16 -u new-user
Connecting as new-user to 10.55.2.16 using Test.pem
...
user@localhost $ sshort 16
Connecting as new-user to 10.55.2.16 using Test.pem
...
```
#### `-k`
This forces an update to the key for a node and you will be presented with the list of keys again as if connecting for the first time:

```
user@localhost $ sshort 16 -k
Select a key:
0) id_rsa
1) Dev.pem
...
```

#### `-a`
Add an alias to a node, or move an exisiting alias to a new node, see Aliases section below

### Aliases

If you want to connect to a host using an alias instead of an IP, you can set an alias
```
sshort 16 -a fred
```
Next time you can just use `fred`
```
sshort fred
```

If you set an alias that already exists it will be moved to the new host, 
and a message will inform you:
```
user@localhost $ sshort 0.77 -a fred
Moving alias fred from 10.55.2.16 to 10.55.0.77
...
```

To list all the saved aliases, use the `--list` action:
```
user@localhost $ sshort --list
fav
fred
```

### Push and Pull

ssh-short also provides a way to push/pull files using `scp`:
```
sshort 16 --pull /foo/bar.txt /tmp/
```

This will pull the file `/foo/bar.txt` from the host to the `/tmp` directory on your local machine. 
The opposite is `--push`:
```
sshort 16 --push /tmp/bar.txt /foo/
```

Behind the scenes ssh-short uses the same key lookup process, 
and then just passes the path arguments to `scp`:
```
scp -r -i /path/to/key.pem /tmp/bar.txt my-user@10.55.2.16:/foo/
```

## Installation

Install the gem:
```
gem install ssh-short
```

Create your config file

## SSH Config

The SSH config file (`~/.ssh/config`) has support for a lot of this already, as well as extra stuff like `LocalForward` etc

Maybe this tool can evolve to use the SSH config for persistence instead of `~/.ssh-short/nodemap.yml`
and support all the features that SSH and it's config file offer,
however reading and writing wouldn't be as simple as serialising a simple array to/from YAML.

Plus the user might want to make changes to the SSH config outside of ssh-short, so we'd have to careful not to overwrite these "external" changes

## ToDo
- Make `ip_mask` and `default_user` optional config settings
- IPv6??
