# --- Étape de Build ---
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Copie des fichiers de dépendances et téléchargement
COPY go.mod go.sum ./
RUN go mod download

# Copie du reste du code source
COPY . .

# Compilation de l'application statique pour Alpine
RUN CGO_ENABLED=0 GOOS=linux go build -o bricks ./main.go

# --- Étape Finale (Légère et Sécurisée) ---
FROM alpine:3.19

# Installation des certificats CA requis si l'application appelle des API externes (ex: OpenAI, Ollama)
RUN apk --no-cache add ca-certificates

WORKDIR /app

# Récupération du binaire compilé
COPY --from=builder /app/bricks .

# Copie éventuelle des assets statiques si votre application en utilise
# COPY --from=builder /app/public ./public 

# Configuration du port d'écoute (à adapter selon les variables d'environnement de Bricks)
EXPOSE 8080

# Commande de démarrage
CMD ["./bricks"]
