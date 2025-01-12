# Etapa 1: Construção
FROM node:18-alpine AS builder

# Define o diretório de trabalho
WORKDIR /app

# Copia apenas os arquivos essenciais para instalar as dependências
COPY package*.json tsconfig.json ./

# Instala as dependências
RUN npm ci

# Copia o restante dos arquivos do projeto para o build
COPY . .

# Gera o build da aplicação
RUN npm run build

# Etapa 2: Produção
FROM node:18-alpine AS runner

# Define o diretório de trabalho
WORKDIR /app

# Copia apenas os arquivos necessários para a produção
COPY package*.json ./
RUN npm ci --omit=dev

# Copia os artefatos de build gerados na etapa anterior
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.ts ./next.config.ts
COPY --from=builder /app/node_modules ./node_modules

# Define a porta de execução
EXPOSE 3001

# Comando para iniciar o servidor Next.js
CMD ["npm", "start"]
