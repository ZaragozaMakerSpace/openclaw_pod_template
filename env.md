# Variables de entorno del Pod (RunPod)

Este documento incluye solo variables configurables en runtime para este proyecto.

## 1) Runtime general del pod

| Variable     | Default | Notas                                                              |
| ------------ | ------- | ------------------------------------------------------------------ |
| SSH_PASSWORD | root    | Contraseña de root para SSH. Si no se define, se aplica root:root. |

## 2) LLM (vLLM)

| Variable               | Default                            | Notas                                                                     |
| ---------------------- | ---------------------------------- | ------------------------------------------------------------------------- |
| MODEL                  | mistralai/Mistral-7B-Instruct-v0.2 | Modelo HF servido por la API OpenAI-compatible de vLLM.                   |
| PORT                   | 8001                               | Puerto HTTP de vLLM dentro del contenedor.                                |
| GPU_MEMORY_UTILIZATION | 0.85                               | Fracción de VRAM usada por vLLM.                                          |
| PARSER                 | hermes                             | Valor de --tool-call-parser para vLLM.                                    |
| TOKENIZER_MODE         | auto                               | Modo de tokenizer de vLLM (`auto`, `slow`, `mistral`, `custom`).          |
| MAX_MODEL_LEN          | (vacío)                            | Si se define, fuerza `--max-model-len`; vacío = usa el máximo del modelo. |

## 3) OpenClaw (arranque actual del contenedor)

| Variable       | Default           | Notas                                                                              |
| -------------- | ----------------- | ---------------------------------------------------------------------------------- |
| OPENCLAW_TOKEN | 123456 (fallback) | Token configurable desde RunPod; start.sh lo transforma en OPENCLAW_GATEWAY_TOKEN. |

## 4) OpenClaw (solo si usas scripts/start_openclaw.sh)

Estas variables son configurables si cambias el arranque para usar scripts/start_openclaw.sh.

| Variable               | Default                                          | Notas                                              |
| ---------------------- | ------------------------------------------------ | -------------------------------------------------- |
| OPENCLAW_HOME          | /workspace/.openclaw                             | Home de OpenClaw en el script alternativo.         |
| OPENCLAW_STATE_DIR     | /workspace/.openclaw                             | Directorio de estado en el script alternativo.     |
| OPENCLAW_GATEWAY_TOKEN | a05895181d677ec0accd72ed3f217b1cad567def18dae237 | Token por defecto usado por el script alternativo. |

## Resumen rápido para RunPod

1. SSH_PASSWORD
2. MODEL
3. PORT
4. GPU_MEMORY_UTILIZATION
5. PARSER
6. TOKENIZER_MODE
7. MAX_MODEL_LEN
8. OPENCLAW_TOKEN
