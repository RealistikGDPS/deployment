# deployment
The example deployment for a RealistikGDPS-based server. It contains:
- All of the required services as submodules.
- Docker and Compose files linking them all together.
- Example configuration files.

- This is what is currently in use on the core RealistikGDPS server.
- This may not always be the case as we may introduce private modules.
- This depends on the Ognisko refactor which is **currently unfinished**.


## Configuration
Configuration is done through service-specific environment files. You may find example files within the `./configuration/*.env.example`. Additionally, a `.env.example` is provided inside the root of the repository to specify the local directories used.

## Running
**CURRENTLY NONE OF THE SUBMODULES ARE PLACED IN. THIS WILL BE DONE WHEN THE RESTRUCTURE OF OGNISKO IS FINISHED.**
