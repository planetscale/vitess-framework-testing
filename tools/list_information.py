'''
List Information
   - Frameworks avaliable
   - Docker Images
   - Docker Containers
'''
import glob
import pathlib
import docker
from tabulate import tabulate

# Get docker information from environment variables
client = docker.from_env()

def frameworks_on_disk():
    frameworks = []
    for framework in glob.glob('frameworks/*/*'):
        framework_parts = pathlib.Path(framework).parts[1:]
        frameworks.append(str(pathlib.Path(*framework_parts)))

    # Prints all frameworks avaliable
    for framework in sorted(frameworks):
        print(framework)

    #return sorted(frameworks)

# Prints images that only belong with prefix vft-
def images_on_disk():
    # Shape [[Docker tag, short id],..n]
    images_output = []

    for i in client.images.list():
        if len(i.tags) > 0:
            # Filter images and add to list only required ones
            if i.tags[0].startswith("vft-"):
                images_output.append([str(i.tags[0]),str(i.short_id)])

    # Prints in table format
    print(tabulate(images_output, ["Tag name","Short ID"], tablefmt="pretty"))

# Print containers that only belong with prefix vft-
def containers_on_disk():
    # Shape [[Docker tag, Name, status,ports],..n]
    containers_output = []

    for i in client.containers.list():
        if i.image.tags[0].startswith("vft-"):
           containers_output.append([i.image.tags[0],i.name,i.status,i.ports])
    print(containers_output)

    #Prints in table format
    print(tabulate(containers_output, ["Docker Tag","Name","Status","Port"], tablefmt="pretty"))
