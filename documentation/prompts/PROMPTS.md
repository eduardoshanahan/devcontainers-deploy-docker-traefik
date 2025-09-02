# Prompts used while working with Cursor

## Starting a new session

### To continue working

```text
hello! 
We are continuing working on this project together. Please read all the files, in full, and get familiar on how it is implemented. 
Please remember that  we have a set of rules to follow described at .cursor/rules.
You don't need to explain me what you learn, just report back when you are ready to go.
```

```text
Hello! We are continuing work on an Ansible project to deploy a static web page running in a Docker container, with Traefik as a reverse proxy already configured and running on the server.
PROJECT STATUS:
Complete Ansible role structure built (src/roles/deploy_static_web/)
Inventory and group_vars configured
Main playbook created (src/playbooks/deploy_static_web.yml)
Deployment script updated (scripts/deploy.sh)
Environment files cleaned up (.env, .env.example)
Devcontainer Dockerfile updated to include community.docker collection
```

```text
hello!
We are going to be working together on this project.
We are going to write ansible scripts to deploy a static web page running in a Docker container. The server hosting the page already has Docker installed and configured and also Traefik as a reverse proxy also running in a container. Traefik is expecting to receive our page, and many variables are already configured.
Please review the whole traefik deployment that you have acessible at devcontainers-deploy-docker-traefik. The details of the deployment of the VOS are inside it, located at devcotnainers-deploy-docker. The deployment environment is production.
Please remember that I want to abide by the rules present at .cursor/rules.
Also, I want to have, at the end of our work, ansible scripts that can be used repeatedly, and wich will succeed every time.
Please keep brief notes about what we are goiing to do, and the status at each point, in the documentation directory. They are for yourself, to be able to restart work each time we start a new session.
```

```text
We are going to be working together around this project. when you edit or create new files, please remember to apply the rules at .cursor/rules before showing your suggestions. Please analyse the existing project, in full, to know what we are trying to do. You don't need to explain me what you learnt, just report back when you are done understanding.
```

```text
good morning! 
We are going to try to deploy traefik into my vps tpday.
When you sugest some code, please remember to apply the rules at .rules/cursor.
Please remember that you have full access to the project used to deploy Docker on my VPS on the directory devcontainer-deploy-docker, if you need to investigqate what is the situation in the VPS that will be your starting point.
there is no integration required. devcontainers-deploy-docker is just a reference for you to understand how the deployment and maintenance of docker is done, and the coding standards used, but the directory will be removed in the end. no changes should be done there. The traefik deployment has to be independent, able to be done repeatedly without breaking the docker deployment, and able to recognize other containers deployed by other projects.
If something needs to be changed on the server and it is not specific to our task (which is to deploy Traefik as a reverse proxy for other containers) please prepare for me the instructions to have that changed in the project devcontaienrs-deploy-docker, and I will pass it to the other team to work on it. Do not make changes to the files in that directory.
Please remember that I want to have things done by way of Ansible as much as possible. Running some bash commands is ok, doing an ocasional ssh into the vps is ok, but I am not interested in quick fixes, at the end of our effort we want to have Ansible scripts that run flawlesly the next time.
Please keep in mind that there is an existing inventory created, and there are three environments to maintain, development, staging and production. Please remember that I want to have variables in a central location, not hardcoded values in different files.
We will go one step at a time. devcontainers-deploy-docker-traefik is just a reference. we are not going to do any modifications to it. but you can use it as a guideline of the structure that we want to have in our src directory, and also to check with variables and values are already available.
If you have sugestions on files and directories needed, please present to me here and I will do them
```

```text
good morning!
We are going to enhance the deployment of Traefik in my VPS. It is already working correctly, now we are making it better.
```

```text
"Hello! I'm resuming work on my Traefik security enhancement project. Here's the current status:
Current State:
Traefik is successfully deployed and running on my VPS
SSL/Let's Encrypt is working correctly
I now have a test domain/page deployed behind Traefik for testing security features
What We're Doing:
Implementing high-priority security enhancements one by one
Starting with WAF (ModSecurity) integration
Testing each feature thoroughly before moving to the next
Documentation Available:
Security enhancements roadmap in documentation/research-and-development/implementation/security-enhancements.md
Implementation plan in documentation/research-and-development/implementation/implementation-plan.md
Current project state and configurations
Next Steps:
Begin WAF integration with ModSecurity
Test with the new test domain
Deploy and validate before moving to rate limiting
Please analyze the current project state and let me know when you're ready to start implementing the WAF integration."
What I'll Do in the Next Session
Analyze current project state and verify Traefik is working
Review the security roadmap and implementation plan
Start with WAF integration (ModSecurity + OWASP CRS)
Test thoroughly with your new test domain
Move to the next security feature only after success
```
