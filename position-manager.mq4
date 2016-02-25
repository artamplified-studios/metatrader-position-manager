//+------------------------------------------------------------------+
//|                                        Position Manager 0.1.0    |
//|                                Copyright 2016, Kiran Mertopawiro |
//|                                      http://www.artamplified.com |
//+------------------------------------------------------------------+

extern int maxRisk = 150;
extern double profit = 500;
extern double lots = 2.00;
extern int amountPartialTarget = 2;

int totalPositions = 0;

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


//	Handles all live trades
void positionManager()
{

	double partialTarget;
	int pt;

	for( int i=0; i<OrdersTotal(); i++ ) {
		if(OrderSelect( i, SELECT_BY_POS, MODE_TRADES) == true && OrderSymbol() == Symbol() ) {

			//	close partial target when hit
			switch( OrderType() ) {
				//	buy
				case 0:
					
					for( pt=0; pt<amountPartialTarget; pt++) {

						if( ObjectFind(0, (string)OrderTicket() + " target "+(string)pt ) != 0 ) {
							return;
						} 

						partialTarget = ObjectGet( (string)OrderTicket() + " target "+(string)pt, 1 );

						if( OrderLots() > (lots/2)) {
							if( MarketInfo( Symbol(), MODE_BID ) > partialTarget ) {
								OrderModify( OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + 30*Point, OrderTakeProfit(), 0, Green );
								OrderClose( OrderTicket(), OrderLots()/2, MarketInfo(Symbol(), MODE_BID), 0, DarkGreen );
							}
						} 

						if( OrderLots()  == (lots/2)) {
							if( MarketInfo( Symbol(), MODE_BID ) > partialTarget ) {
								Print("Close partialTarget:");
								OrderClose( OrderTicket(), OrderLots()/2, MarketInfo(Symbol(), MODE_BID), 0, DarkGreen );
							}
						}
					}

				break;

				//	sell
				case 1:

					for( pt=0; pt<amountPartialTarget; pt++) {

						if( ObjectFind(0, (string)OrderTicket() + " target "+(string)pt ) != 0 ) {
							return;
						} 

						partialTarget = ObjectGet( (string)OrderTicket() + " target "+(string)pt, 1 );

						if( MarketInfo( Symbol(), MODE_ASK ) < partialTarget ) {

							//	if target 0 hit
							//	move stops to breakeven
							//	close partial target
							if( OrderLots() > (lots/2)) {
								OrderModify( OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - 30*Point, OrderTakeProfit(), 0, Green );
								OrderClose( OrderTicket(), OrderLots()/2, MarketInfo(Symbol(), MODE_ASK), 0, DarkGreen );
							} 

							if( OrderLots()  == (lots/2)) {
								OrderClose( OrderTicket(), OrderLots()/2, MarketInfo(Symbol(), MODE_ASK), 0, DarkGreen );
							}

							historyManager( OrderTicket() );

						}
						
					}

				break;

			}

		}
	}
	
};
//	--

//	Handles all new orders
//	Creates new partial targets
void orderManager()
{

	//	if long script is executed
	//	open order with default settings
	if( GlobalVariableCheck( "long" ) ) {
		OrderSend( Symbol(), OP_BUY, lots, MarketInfo( Symbol(), MODE_ASK), 3, 0, 0);
		GlobalVariableDel( "long" );
	}
	//	--

	//	if short script is executed
	//	open order with default settings
	if( GlobalVariableCheck( "short" ) ) {
		OrderSend( Symbol(), OP_SELL, lots, MarketInfo( Symbol(), MODE_BID), 3, 0, 0);
		GlobalVariableDel( "short" );
	}
	//	--

	//	Prevent overhead
	if( totalPositions == OrdersTotal() ) {
		return;
	}
	Print("new order");

	//	set new totalPositions
	totalPositions = OrdersTotal();


	double newOrderStopLoss;
	double newOrderTakeProfit;
	double partialTarget;

	//	Select last new order
	if( OrderSelect( OrdersTotal()-1, SELECT_BY_POS, MODE_TRADES) == true && OrderSymbol() ) {

		//	if no stop loss
		//	set default settings for new order
		if( OrderStopLoss() == 0 ) {

			//	check if long/short position
			switch( OrderType() ) {
				//	buy
				case 0:
				newOrderStopLoss = OrderOpenPrice() - (maxRisk * Point);
				newOrderTakeProfit = OrderOpenPrice() + ( profit * Point);
				OrderModify( OrderTicket(), OrderOpenPrice(), newOrderStopLoss, newOrderTakeProfit, 0, Green );
				break;
				//	sell
				case 1:
				newOrderStopLoss = OrderOpenPrice() + (maxRisk * Point);
				newOrderTakeProfit = OrderOpenPrice() - ( profit * Point);
				OrderModify( OrderTicket(), OrderOpenPrice(), newOrderStopLoss, newOrderTakeProfit, 0, Green );
				break;

			}

		}

	}
	
	/*
	if(OrdersTotal() > 0) {

		//	itterate over each order
		for(int i=0; i<OrdersTotal(); i++) {
			if(OrderSelect( i, SELECT_BY_POS, MODE_TRADES) == true && OrderSymbol() == Symbol() ) {

				//	if instant order and no stop loss
				// 	set default order settings
				if( OrderStopLoss() == 0) {

					//	set default OrderStopLoss && OrderTakeProfit
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

					//	init new position and add to list


					// set partial targets
					if( amountPartialTarget > 0 ) {

						for( int pt=0; pt< amountPartialTarget; pt++) {
							if( ObjectFind(0, OrderTicket() + " target "+pt != 0 )) {

								switch( OrderType() ) {
									//	buy
									case 0:
									partialTarget = newOrderTakeProfit - ( ( profit / ( 2+pt) ) * Point);
									ObjectCreate(0,  (string)OrderTicket() + " target "+(string)pt ,OBJ_HLINE, 0,0, partialTarget );
									ObjectSetInteger( 0, (string)OrderTicket() + " target "+(string)pt , OBJPROP_COLOR, Orange );
									ObjectSetInteger( 0, (string)OrderTicket() + " target "+(string)pt , OBJPROP_STYLE, STYLE_DASH );
									break;

									//	sell
									case 1:
									partialTarget = newOrderTakeProfit + ( ( profit / ( 2+pt) ) * Point);
									ObjectCreate(0,  (string)OrderTicket() + " target "+(string)pt ,OBJ_HLINE, 0,0, partialTarget );
									ObjectSetInteger( 0, (string)OrderTicket() + " target "+(string)pt , OBJPROP_COLOR, Orange );
									ObjectSetInteger( 0, (string)OrderTicket() + " target "+(string)pt , OBJPROP_STYLE, STYLE_DASH );
									break;
								}
								
							}
						}

					}
					//	--

				}
				// --

			}
		}
		//	--

		positionManager();

	}
	*/

};
//	--


//	History manager
//	Manage all history orders
void historyManager( int _orderTicket ) {

	string objectName;
	double partialTarget[];
	//Position* historyOrder;
	double historyOrderOpenPrice;


	if( OrderSelect( _orderTicket, SELECT_BY_TICKET, MODE_HISTORY) == true && OrderSymbol() == Symbol() ) {
		
		for( int pt=0; pt<amountPartialTarget; pt++ ) {
			objectName = (string)OrderTicket() + " target "+(string)pt;
			historyOrderOpenPrice = OrderOpenPrice();

		 	if( ObjectFind( 0, objectName == 0 ) ) {
		 		partialTarget[pt] = ObjectGet( objectName, 1 );
		 		//	check if open trade has same openPrice as history trade

		 		ObjectDelete( objectName );
		 	}
		}

	}

	Print("partialTargets: ", partialTarget[0], partialTarget[1] );
	Print("historyOrderOpenPrice: ", historyOrderOpenPrice );

	for( int j=0; j<OrdersTotal(); j++ ) {

		if( OrderSelect( j, SELECT_BY_POS, MODE_TRADES) == true && OrderSymbol() == Symbol() ) {
			if( OrderOpenPrice() == historyOrderOpenPrice ) {
				for( int newpt=0; newpt < amountPartialTarget; newpt++) {
					ObjectCreate(0,  (string)OrderTicket() + " target "+(string)newpt ,OBJ_HLINE, 0,0, partialTarget[newpt] );
					ObjectSetInteger( 0, (string)OrderTicket() + " target "+(string)newpt , OBJPROP_COLOR, Blue );
					ObjectSetInteger( 0, (string)OrderTicket() + " target "+(string)newpt , OBJPROP_STYLE, STYLE_DASH );
				}
			}
		}
	}


}



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










