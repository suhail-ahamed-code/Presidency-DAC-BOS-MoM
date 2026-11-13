
# Stage 1: Build the frontend
FROM node:20-slim AS frontend-build

WORKDIR /frontend

COPY frontend/package.json ./
RUN npm install --no-audit --no-fund

COPY frontend/ ./
RUN npm run build


# Stage 2: Run the Python application
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt gunicorn

COPY . .

COPY --from=frontend-build /frontend/dist ./frontend/dist

RUN mkdir -p /app/data

EXPOSE 8000

CMD ["sh", "-c", "exec gunicorn --bind 0.0.0.0:${PORT:-8000} --workers 1 --threads 4 --timeout 120 app:app"]
