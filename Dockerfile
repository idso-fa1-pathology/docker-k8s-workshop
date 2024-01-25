# base image
FROM python:slim

# install libraries
# here I am only installing a little rather useless library
# this is where you can install anything else that the base image
# doesnt include, same as you would in creating a conda environment
# alternative approach: 
# - create a requirements.txt
# - copy it inside: COPY ./requirements.txt 
# - add command: RUN pip install -r requirements.txt 
RUN pip install cowsay


# entrypoint command: open a terminal window
CMD ["/bin/bash"]
