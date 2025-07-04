# Estágio 1: Builder - Instala dependências, incluindo as de compilação
FROM python:3.12-alpine AS builder

# Define o diretório de trabalho
WORKDIR /usr/src/app

# Instala dependências a nível de SO para compilação de pacotes Python
# build-base é necessário para compilar algumas dependências
RUN apk add --no-cache build-base

# Copia e instala as dependências Python para otimizar o cache de layers
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---

# Estágio 2: Imagem Final - A imagem de execução, otimizada e segura
FROM python:3.12-alpine

# Cria um usuário e grupo não-root para rodar a aplicação por segurança
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Define o diretório de trabalho para o usuário não-root
WORKDIR /home/appuser

# Copia os executáveis (como uvicorn) e as bibliotecas Python do estágio builder
COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY --from=builder /usr/local/lib/python3.12/site-packages/ /usr/local/lib/python3.12/site-packages/

# Copia o código da aplicação e define o usuário não-root como dono
COPY --chown=appuser:appgroup . .

# Alterna para o usuário não-root
USER appuser

# Expõe a porta em que a aplicação irá rodar
EXPOSE 8000

# Comando para iniciar a aplicação
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]