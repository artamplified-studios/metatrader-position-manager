//+------------------------------------------------------------------+
//|                                        Position Manager 0.1.0    |
//|                                Copyright 2016, Kiran Mertopawiro |
//|                                      http://www.artamplified.com |
//+------------------------------------------------------------------+

extern int maxRisk = 150;
extern double profit = 500;
extern double lots = 2.00;

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
	orderManager();
   
  }
//+------------------------------------------------------------------+

//	init position object
class Position;
Position *position;

class History;
History *history;	


//	Handles all live trades
void positionManager()
{


	
};
//	--

//	Handles all new orders
//	Creates new partial targets
void orderManager()
{

	double newOrderStopLoss;
	double newOrderTakeProfit;
	
	if(OrdersTotal() > 0) {
		for(int i=0; i<OrdersTotal(); i++) {
			if(OrderSelect( i, SELECT_BY_POS, MODE_TRADES) == true && OrderSymbol() == Symbol() ) {

				//	if instant order and no stop loss
				// 	set default order settings
				if( OrderStopLoss() == 0) {
					Print( OrderType() );
					switch( OrderType() ) {
						// buy
						case 0:
						newOrderStopLoss = OrderOpenPrice() - (maxRisk * Point);
						newOrderTakeProfit = OrderOpenPrice() + ( profit * Point);
						OrderModify( OrderTicket(), OrderOpenPrice(), newOrderStopLoss, newOrderTakeProfit, 0, Green );
						break;

						// sell
						case 1:
						newOrderStopLoss = OrderOpenPrice() + (maxRisk * Point);
						newOrderTakeProfit = OrderOpenPrice() - ( profit * Point);
						OrderModify( OrderTicket(), OrderOpenPrice(), newOrderStopLoss, newOrderTakeProfit, 0, Green );
						break;
					}
				}

				//	init new position



			}
		}
	}

};
//	--

Position* list[];

//	Place all orders in history
class History{

	void push(Position* _position) {
		Print("hello");
	}
};




class Position
{
	private:
		int orderTicket;
		double orderOpenPrice;
		double orderStopLoss;
		double orderTakeProfit;
		double orderLots;
		//bool hasPartialTakeProfit = false;

	public:

		void setOrderTicket( int _orderTicket ) { orderTicket = _orderTicket; };
		int getOrderTicket() { return orderTicket; };

		void setOrderOpenPrice( double _orderOpenPrice ) { orderOpenPrice = _orderOpenPrice; };
		double getOrderOpenPrice() { return orderOpenPrice; };

		void setOrderStopLoss( double _orderStopLoss ) { orderStopLoss = _orderStopLoss; };
		double getOrderStopLoss() { return orderStopLoss; };

		void setOrderTakeProfit( double _orderTakeProfit ) { orderTakeProfit = _orderTakeProfit; };
		double getOrderTakeProfit() { return orderTakeProfit; };

		void setOrderLots( double _orderLots ) { orderLots = _orderLots; };
		double getOrderLots() { return orderLots; };
};










