FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# ExecutorはCLI起動型 → EXPOSE不要
CMD ["python", "executor.py"]
