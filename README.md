# AWS Elastic Beanstalk with Nginx / PHP-FPM 

## Overview

By default PHP on Elastic Beanstalk runs on Apache, which is also a dependancy of Hostmanager. The goal of this project is to provide an easy way to replace Apache with Nginx / PHP-FPM. To use, transfer the build script onto a fresh Beanstalk AMI instance, and execute elasticbeanstalk-lemp.sh script.

## Example installation

- Create a new EC2 instance using any preconfigured PHP Beanstalk image - use "Launch More Like This" command;
- SSH into the instance as root and run the script:

```bash
wget https://raw.githubusercontent.com/gabrielPav/elasticbeanstalk-lemp/master/elasticbeanstalk-lemp.sh
chmod +x elasticbeanstalk-lemp.sh
bash elasticbeanstalk-lemp.sh
```

- Exit SSH, and create AMI image from the customized instance;
- Set your EB application's custom AMI ID to the new image and save the configuration.
