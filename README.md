# OpenClaw RunPod

Imagen Docker pensada para **RunPod** (u otro host con GPU NVIDIA): levanta **OpenClaw Gateway**, un servidor **vLLM** compatible con OpenAI, **JupyterLab** y **SSH**, todo coordinado con **supervisord**.

## Cómo funciona el sistema

1. **Arranque del contenedor** (`/start.sh`): crea directorios bajo `/workspace`, aplica la contraseña de root para SSH (ver variables abajo) y arranca **supervisord** en primer plano.

2. **Supervisord** ejecuta cuatro procesos (orden de prioridad):

   | Programa   | Rol |
   |------------|-----|
   | `sshd`     | Servidor SSH (puerto 22). |
   | `jupyter`  | JupyterLab en `0.0.0.0:8888`, sin token (`NotebookApp.token=''`). |
   | `llm`      | Script `scripts/start_llm.sh`: lanza **vLLM** (`python -m vllm.entrypoints.openai.api_server`) con el modelo y puerto configurables por entorno. |
   | `openclaw` | `openclaw gateway run --port 18789 --allow-unconfigured`: el **Gateway** de OpenClaw (WebSocket, APIs de control, etc.) sin exigir `gateway.mode=local` en el fichero de configuración (modo práctico para contenedores / primera subida). |

3. **OpenClaw** es el servicio que expone el gateway de la plataforma (canales, sesiones, API compatible OpenAI en el gateway según la [documentación oficial](https://docs.openclaw.ai/gateway/)). En esta imagen corre en el puerto **18789**.

4. **vLLM** sirve el modelo LLM en **HTTP** (por defecto puerto **8001**) con API estilo OpenAI, para que agentes o clientes apunten al endpoint del contenedor.

5. **Caché Hugging Face**: `HF_HOME` y `TRANSFORMERS_CACHE` apuntan a `/workspace/hf` (también en el script del LLM), para persistir descargas si montas un volumen en `/workspace`.

**Puertos expuestos** (según el `Dockerfile`): **22** (SSH), **8888** (Jupyter), **8001** (vLLM), **18789** (OpenClaw Gateway).

**Logs**: `/workspace/logs/` (`supervisord.log`, `jupyter.log`, `llm.log`, `openclaw.log`, y los `.err` correspondientes).

## Variables de entorno

### Usadas directamente por esta imagen

| Variable | Obligatoria | Valor por defecto | Descripción |
|----------|-------------|-------------------|-------------|
| `SSH_PASSWORD` | No | `root` | Contraseña del usuario **root** para SSH. Si no se define, se mantiene `root:root` (mismo comportamiento que la capa del Dockerfile). **En producción conviene fijarla y usar claves SSH si el proveedor lo permite.** |
| `MODEL` | No | `mistralai/Mistral-7B-Instruct-v0.2` | Identificador Hugging Face del modelo que cargará **vLLM**. |
| `PORT` | No | `8001` | Puerto **HTTP** del servidor OpenAI de **vLLM** (no es el puerto del Gateway OpenClaw). |

El script del LLM también fija `HF_HOME` y `TRANSFORMERS_CACHE` a `/workspace/hf` por código; el `Dockerfile` define los mismos valores en la imagen.

### Parámetros fijados en configuración (no por env en el repo actual)

Si necesitas cambiarlos, hay que editar **`supervisord.conf`** o el **`Dockerfile`** y reconstruir:

- Puerto y token de **Jupyter** (`8888`, token vacío).
- Puerto y flags de **OpenClaw** (`18789`, `--allow-unconfigured`).
- Argumentos de **vLLM** en `scripts/start_llm.sh` (por ejemplo `--gpu-memory-utilization 0.85`, `--trust-remote-code`).

### OpenClaw: variables que reconoce el CLI (referencia)

El binario `openclaw` puede usar otras variables según la [documentación del Gateway](https://docs.openclaw.ai/gateway/), por ejemplo:

| Variable (documentación upstream) | Uso típico |
|-----------------------------------|------------|
| `OPENCLAW_GATEWAY_PORT` | Puerto del gateway si no se pasa `--port` (en esta imagen el comando lleva `--port 18789`). |
| `OPENCLAW_CONFIG_PATH` | Ruta alternativa al fichero de configuración. |
| `OPENCLAW_STATE_DIR` | Directorio de estado (sesiones, credenciales, etc.). |

Para que surtan efecto con el proceso que arranca supervisord, habría que **exportarlas en el entorno del contenedor** y, si hace falta, **ajustar la línea `command=`** de `[program:openclaw]` para alinear puerto, token o modo de autenticación con tu despliegue.

## Build local

```bash
docker build -t openclaw-runpod .
```

## RunPod (resumen)

- Asocia los puertos **22, 8888, 8001, 18789** según necesites.
- Monta un volumen en **`/workspace`** para conservar modelos, caché HF (`/workspace/hf`), notebooks y logs entre reinicios.
- Define al menos **`SSH_PASSWORD`** si no quieres la contraseña por defecto de root.
- Ajusta **`MODEL`** al modelo que quepa en tu GPU; los modelos grandes pueden requerir más VRAM o cuantización (esto implicaría cambiar el comando vLLM en `scripts/start_llm.sh`).

## Seguridad

- Jupyter está configurado **sin token**; expón **8888** solo en redes confiables o detrás de túnel/VPN.
- El gateway se arranca con **`--allow-unconfigured`**, pensado para entornos controlados; para producción revisa auth y configuración en [OpenClaw Gateway](https://docs.openclaw.ai/gateway/).
