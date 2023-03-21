c = get_config()

c.ServerApp.token = ""
c.ServerApp.password_required = False
c.ServerApp.open_browser = False
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}
