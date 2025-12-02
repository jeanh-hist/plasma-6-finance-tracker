#!/usr/bin/env python3
"""
Backend para widget KDE Finance Tracker
Retorna dados em formato JSON para o QML
"""

import yfinance as yf
import json
import sys

def get_ticker_data(symbol):
    """Obtém dados de um ticker específico"""
    try:
        ticker = yf.Ticker(symbol)
        hist = ticker.history(period="1mo")
        
        if hist.empty:
            return None
        
        info = ticker.info
        
        # Preço atual e variações
        current_price = hist['Close'].iloc[-1]
        open_price = hist['Open'].iloc[-1]
        day_change = ((current_price - open_price) / open_price) * 100
        
        # Variação 7 dias
        if len(hist) >= 7:
            week_price = hist['Close'].iloc[-7]
            week_change = ((current_price - week_price) / week_price) * 100
        else:
            week_change = 0
        
        # Variação 30 dias
        month_price = hist['Close'].iloc[0]
        month_change = ((current_price - month_price) / month_price) * 100
        
        # Nome do ativo
        name = info.get('longName') or info.get('shortName', symbol)
        
        return {
            'symbol': symbol,
            'name': name,
            'price': float(current_price),
            'change': float(day_change),
            'change7d': float(week_change),
            'change30d': float(month_change),
            'high': float(hist['High'].max()),
            'low': float(hist['Low'].min()),
            'volume': float(hist['Volume'].mean())
        }
    
    except Exception as e:
        print(f"[ERRO] {symbol}: {str(e)}", file=sys.stderr)
        return None

def main():
    """Função principal"""
    if len(sys.argv) < 2:
        print(json.dumps([]))
        return
    
    # Recebe símbolos como argumentos
    symbols = sys.argv[1:]
    
    results = []
    for symbol in symbols:
        data = get_ticker_data(symbol.strip())
        if data:
            results.append(data)
    
    # Retorna JSON
    print(json.dumps(results))

if __name__ == "__main__":
    main()
