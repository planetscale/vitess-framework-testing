'''
Runs framework tests
'''
import docker
import os

# Get docker information from environment variables
client = docker.from_env()

# Runs a specific framework
def build_run_framework(name):
    framework_image_path = "frameworks/" + name
    tag_name = "vft-" + name

    # Check if image is already exists (If already exists then delete and rebuild)
    try:
       client.images.get(tag_name)
       print("------ Image exists --------")
    except:
       print("------ Image does not exists (building " + name + " and running image) ---------")

       # Running as bash command (TODO: switch it to python docker api)-> Ex: client.images.build(path=framework_image_path,tag=tag_name)
       # client.images.build(path=framework_image_path,tag=tag_name,rm=True)
       # Running interactive version until log files for results are created
       os.system("docker build -t " + tag_name + " " + framework_image_path)


    # Building image
    #docker.build(framework_image_path,tag_name)
