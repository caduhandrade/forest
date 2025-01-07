# Etapa 1: Construção
FROM node:18-alpine AS builder

# Define o diretório de trabalho
WORKDIR /app

# Copia os arquivos necessários
COPY package.json package-lock.json ./

# Instala as dependências
RUN npm install

# Copia o restante dos arquivos do projeto
COPY . .

# Gera o build da aplicação
RUN npm run build

# Etapa 2: Produção
FROM node:18-alpine AS runner

# Define o diretório de trabalho
WORKDIR /app

# Instala apenas dependências de produção
COPY package.json package-lock.json ./
RUN npm install --omit=dev

# Copia o build da etapa anterior
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.js ./next.config.js
COPY --from=builder /app/node_modules ./node_modules

# Define a porta de execução
EXPOSE 3000

# Comando para iniciar o servidor Next.js
CMD ["npm", "start"]
