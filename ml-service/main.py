from fastapi import FastAPI

app = FastAPI(title="GIGGO ML Service")

@app.get("/health")
def health_check():
    return {"status": "ok"}

# Meaning: this creates a tiny web app with one address, /health, 
# that returns {"status": "ok"}. 
# Why: a "health check" endpoint is the standard first thing to build
# it proves the service starts and responds before you add any real ML code.
# You'll use it later so the system can tell whether the ML service is alive.