# Docker and Kubernetes Demo

Welcome to this demo. Here you'll find a Python script, a Dockerfile, and a job submission yaml file, job-runner.sh. This is all you need to create a simple docker image, create a docker container, and run the container on kubernetes. Lets dive in!

## Part 1. Build a simple docker image on your local machine

Note: everything here is for mac. It might be slightly different for windows.

1. Create a docker image on your machine using the dockerfile. We are going to call it demo:latest.
```
$ cd <current directory>
$ docker build -t demo:latest .
```

2. Run the docker on your local machine
```
$ docker run demo
```
Did it do what you wanted? Did you expect it to do anything? Try the interactive mode:
```
$ docker run -it demo
```

3. Explore!
   - Run the container in interactive mode and examine the folder structure inside. Check python version and see if you can import cowsay.
   - Make your own python script, add libraries, build, and run again.
   - How can you keep organize images? 
      - use relevant and meaningful tags. In a week, you won't remember what 'v2' means.
      - Make use of hpcharbor and dockerhub as repositories.
      - Also, you can always save images to local tar files using `docker image save ..`

4. Explore changing the docker by creating a code directory and copying the python file inside.

5. Explore mounting the code directory to the container:
```docker run -it <code_directory>:/data demo``` 

5. see Ping's Dockerfiles for deep learning here: https://github.com/idso-fa1-pathology/K8S-Cluster-Env.git

## Part 2. Upload image to HPCharbor 

Before you proceed, I am going to make some changes to the docker image to make it compatible for running on ubuntu (kubernetes)  

1. Rebuild the image using `--platform=linux/x86_64` argument. We need to make sure the image can run on the kubernetes environment (ubuntu):
```
$ docker build --platform linux/x86_64 -t demo:latest-x86_64 .
```

3. Tag it for HPC harbor upload and Push it to YOUR FOLDER on (https://hpcharbor.mdanderson.edu/harbor/projects). 
   
```
$ docker tag demo:latest-x86_64 hpcharbor.mdanderson.edu/<your_folder>/demo:latest-x86_64
$ docker push hpcharbor.mdanderson.edu/<your_folder>/demo:latest-x86_64
```

## Part 3. kubernetes checklist and set up

Before we proceed, ensure that your kubernetes account is set up, that your HOME directory (/rsrch4/home/plm/<username>) has been mounted, and that your HOME directory includes a `.kube` folder with a config file inside. There should be a `K8s-templates` in your home directory. Take a look at your templates. Make sure your `securityContext.runAsUser` matches your employee id, and that `volumeMounts` is your HOME directory.

- First time use, you need to load the kubectl module in seadragon using the following command. It will give a warning that you can ignore.

```
$ ssh seadragon
$ module load kubectl/1.25.6
```

Note, the module (kubectl) is the command itself. See if `kubectl` is a recognized command.

## Part 4. Submitting a kubernetes job

1. Decide if you want to run a cpu or gpu job. The kubernetes context needs to match the job template you are using.
   - run `kubectl config get-contexts` to find out your active kubernetes context.
   - you can switch between the two using:
      - switch to gpu: `kubectl config use-context [Username]_yn-gpu-workload@research-prd`
      - switch to cpu: `kubectl config use-context [Username]_yn-cpu-workload@research-prd`

2. Create YOUR OWM job yaml file.
   - Find the relevant (cpu or gpu) template the `K8s-templates` folder. Your paths are already set up there. 
   - Make sure the path to your HOME is correct everywhere.
   - Copy the template inside the code directory, rename it to something meaningful. As you see here, I renamed mine `job.hello.gpu.yaml` for job-jobname-mycontext.yaml.
   - Change `metadata.name, containers.image, containers.command` appropriately. See `job.hello.gpu.yaml` for reference.
   - Make use of the `containers.args` if your code has any arguments.

Ok, you now have a job template that looks for your docker image on HPCharbor.

3. On seadragon, cd in your code directory. 

4. Run the job using job-runner.sh or using the kubectl apply command.

```
job-runner.sh job.hello.gpu.yaml
```
or 
```
kubectl apply -f <job.yaml>
```

5. Check progress by looking at your job status in OpenLens or you can wait and see what happens. Once the job is done, you will see a `logs` folder and a `done` folder appear in your current directory. Check out the contents of the log folder for details.

I highly recommend installing OpenLens on your machine. It helps a lot with monitoring job progress (Talk to Ping about instructions and setting it up).

## lessons learned

- If the kubernetes fails to run the job and the log file says ```exec /usr/local/bin/python: exec format error```, go back to Part 2.1.
- Make sure you are using the latest version of the yaml templates.
