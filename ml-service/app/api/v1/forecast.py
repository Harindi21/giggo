from fastapi import APIRouter, Depends

from app.core.security import require_api_key
from app.schemas.forecast import ForecastRequest, ForecastResponse
from app.services import forecast_service

router = APIRouter(prefix="/forecast", tags=["forecast"])


@router.post("", response_model=ForecastResponse)
async def create_forecast(payload: ForecastRequest, _=Depends(require_api_key)):
    preds, trend, method = forecast_service.forecast(payload.series, payload.horizon)
    return ForecastResponse(forecast=preds, trend=trend, method=method)
