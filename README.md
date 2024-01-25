# Docker and Kubernetes Demo

In this directory you'll find a Python script, a Dockerfile, and a job submission yaml file, job-runner.sh. This is all you need to create a simple docker image and run the container on kubernetes. Lets dive in!

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

3. explore:
   - make it start from the terminal. once you do, examine the folder structure inside.
   - make it automatically run the hello.py script.
   - make your own, add libraries, build, and run again.
   - How can you keep track of changes?
   - how do you resrrect old images?
      - make use of hpcharbor and dockerhub as repositories.
      - also, you can always save them out to local tar files using `docker image save ..`

4. what are some other commands you could use? Can you get it to run your python code?
   - explore copying the python file inside vs. compare it with mounting the code directory
   
5. see Ping's Dockerfiles for deep learning here: https://github.com/idso-fa1-pathology/K8S-Cluster-Env.git

## Part 2. Upload image to HPCharbor 

Before you proceed, I am going to make some changes to the docker image to make it compatible for running on ubuntu (kubernetes)  

1. rebuild the image using `--platform=linux/x86_64` argument. We need to make sure the image can run on the kubernetes environment:
```
$ docker build --platform linux/x86_64 -t demo:latest-x86_64 .
```

3. Tag it for HPC harbor upload and Push it (https://hpcharbor.mdanderson.edu/harbor/projects). 
   
```
$ docker tag demo:latest-x86_64 hpcharbor.mdanderson.edu/<your_folder>/demo:latest-x86_64
$ docker push hpcharbor.mdanderson.edu/<your_folder>/demo:latest-x86_64
```

## Part 3. kubernetes

Before we proceed, ensure that your kubernetes account is set up, that your HOME directory (/rsrch4/home/plm/<username>) has been mounted, and that your HOME directory includes a `.kube` folder with a config file inside. There should be a `K8s-templates` in your home directory. Take a look at your templates. Make sure your `securityContext.runAsUser` matches your employee id, and that `volumeMounts` is your HOME directory

## Part 4. Submitting a kubernetes job

1. Decide if you want to run a cpu or gpu job. The kubernetes context needs to match the job template you are using.
   - run `kubectl config get-context` to find out your active kubernetes context.
   - you can switch from one to another using:
      - switch to gpu: `kubectl config use-context [Username]_yn-gpu-workload@research-prd`
      - switch to cpu: `kubectl config use-context [Username]_yn-cpu-workload@research-prd`

2. create YOUR OWM job yaml file.
   - find the relevant (cpu or gpu) template the `K8s-templates` folder. Your paths are already set up there. Make sure the path to your HOME is correct everywhere.
   - copy the template inside the code directory, rename it to something meaningful. As you see here, I renamed mine `job.hello.gpu.yaml`.
   - change `metadata.name, containers.image, containers.command`. See `job.hello.gpu.yaml` for reference.

Ok, you now have a job template that looks for your docker image on HPCharbor, and calls `python hello.py` when running it.

3. ssh into your seadragon account and cd inside this directory. 

4. lets run the job. you can do it 2 ways, using job-runner.sh or using the kubectl apply command.

```
job-runner.sh job.hello.gpu.yaml
```
or 
```
kubectl apply -f <job.yaml>
```

5. check progress by looking at your job status in OpenLens or you can wait and see what happens. Once the job is done, you will see a `logs` folder and a `done` folder appear in your directory. Check out the contents of the log folder for details.


## lessons learned

- I highly recommend installing OpenLens on your machine. It helps a lot with monitoring job progress (Talk to Ping about instructions and setting it up) 
- If in Part 3 -> step 4 the log file says ```exec /usr/local/bin/python: exec format error```, go back to Part2 -> step 1.
- Make use of tags for differentiating different versions of your image.ß
