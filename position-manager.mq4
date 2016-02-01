//+------------------------------------------------------------------+
//|                                        Position Manager 0.1.0    |
//|                                Copyright 2016, Kiran Mertopawiro |
//|                                      http://www.artamplified.com |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Print( "Position Manager V0.1.0");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+


//	Handles all live trades
void positionManager()
{

}
//	--

//	Handles all new orders
//	Creates new partial targets
void orderManager()
{

}
//	--


class Position
{
	private:
		int orderTicket;
		double orderOpenPrice;
		double orderStopPrice;
		double orderTakeProfit;
		double orderLots;
		bool hasPartialTakeProfit = false;

	public:

		void setOrderTicket( int _orderTicket ) { orderTicket = _orderTicket; };
		int getOrderTicket() { return orderTicket; };

		void setOrderOpenPrice( double _orderOpenPrice ) { orderOpenPrice = _orderOpenPrice; };
		double getOrderOpenPrice() { return orderOpenPrice; };

		void setOrderStopPrice( double _orderStopPrice ) { orderStopPrice = _orderStopPrice; };
		double getOrderStopPrice() { return orderStopPrice; };

		void setOrderTakeProfit( double _orderTakeProfit ) { orderTakeProfit = _orderTakeProfit; };
		double getOrderTakeProfit() { return orderTakeProfit; };

		void setOrderLots( double _orderLots ) { orderLots = _orderLots; };
		double getOrderLots() { return orderLots; };
};








