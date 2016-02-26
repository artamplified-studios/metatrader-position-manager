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
	positionManager();
   
  }
//+------------------------------------------------------------------+


//	Handles all live trades
void positionManager()
{

	//	prevent overhead
	if( OrdersTotal() == 0 ) {
		return;
	}

	double partialTarget;

	for( int i=0; i<OrdersTotal(); i++ ) {

		//	prevent from executing on multiple symbol charts
		if(	OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == true && OrderSymbol() == OrderSymbol() ) {
			
			for( int pt=0; pt<amountPartialTarget; pt++ ) {

				//	if no partial targets found then stop 
				if( ObjectFind(0, (string)OrderTicket() + " target "+(string)pt ) != 0 ) {
					return;
				} 

				//	find partial target line on chart
				//	and store level
				partialTarget = ObjectGet( (string)OrderTicket() + " target "+(string)pt, 1 );

				//	check long/short order
				switch( OrderType() ) {
					//	buy
					case 0:
						//	if market price hits partial target pt
						//	move stops to break even
						//	close partial position
						if( MarketInfo( Symbol(), MODE_BID ) > partialTarget ) {
							if( OrderLots() > (lots/2) ) {
								OrderModify( OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + 30*Point, OrderTakeProfit(), 0, Green );
								OrderClose( OrderTicket(), OrderLots()/2, MarketInfo(Symbol(), MODE_BID), 0, DarkGreen );
								
								historyManager( OrderTicket() );
							}

							if( OrderLots() >= (lots/2) ) {
								//	todo feature request
								//	maybe trail stop
								//	OrderModify( OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + 30*Point, OrderTakeProfit(), 0, Green );
								OrderClose( OrderTicket(), OrderLots()/2, MarketInfo(Symbol(), MODE_BID), 0, DarkGreen );
								
								historyManager( OrderTicket() );
							}
						}

					break;
					//	sell
					case 1:
						//	if market price hits partial target pt
						//	move stops to break even
						//	close partial position
						if( MarketInfo( Symbol(), MODE_BID ) < partialTarget ) {
							if( OrderLots() > (lots/2) ) {
								OrderModify( OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - 30*Point, OrderTakeProfit(), 0, Green );
								OrderClose( OrderTicket(), OrderLots()/2, MarketInfo(Symbol(), MODE_ASK), 0, DarkGreen );
								
								historyManager( OrderTicket() );
							}

							if( OrderLots() >= (lots/2) ) {
								//	todo feature request
								//	maybe trail stop
								//	OrderModify( OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - 30*Point, OrderTakeProfit(), 0, Green );
								OrderClose( OrderTicket(), OrderLots()/2, MarketInfo(Symbol(), MODE_ASK), 0, DarkGreen );
								
								historyManager( OrderTicket() );
							}
						}

					break;
				}
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
		//	delete global variable to prevent infinite loop
		GlobalVariableDel( "long" );
	}
	//	--

	//	if short script is executed
	//	open order with default settings
	if( GlobalVariableCheck( "short" ) ) {
		OrderSend( Symbol(), OP_SELL, lots, MarketInfo( Symbol(), MODE_BID), 3, 0, 0);
		//	delete global variable to prevent infinite loop
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
		if( OrderStopLoss() == 0 ) {

			//	set default settings for new order
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

			//	if amountPartialTarget > 0
			//	set default partial target based on amount
			if( amountPartialTarget > 0 ) {

				//	check if long/short position
				//	todo:
				//	maybe merge with above switch statement
				for(int pt=0; pt < amountPartialTarget; pt++) {
					switch( OrderType() ) {
						//	buy
						case 0:
						partialTarget = newOrderTakeProfit - ( profit / ( amountPartialTarget + ( amountPartialTarget * pt ) ) * Point ) ;
						break;
						//	sell
						case 1:
						partialTarget = newOrderTakeProfit + ( profit / ( amountPartialTarget + ( amountPartialTarget * pt ) ) * Point ) ;
						break;

					}

					//	create partial target chart line
					//	and add to chart
					ObjectCreate(0,  (string)OrderTicket() + " target "+(string)pt ,OBJ_HLINE, 0,0, partialTarget );
					ObjectSetInteger( 0, (string)OrderTicket() + " target "+(string)pt , OBJPROP_COLOR, Orange );
					ObjectSetInteger( 0, (string)OrderTicket() + " target "+(string)pt , OBJPROP_STYLE, STYLE_DASH );
				}
				
			} else {
				return;
			}

		}

	}
	//	--

};
//	--


//	History manager
//	Manage all history orders
void historyManager( int _orderTicket ) {

	string objectName;
	//	history position
	double historyOrderOpenPrice;
	datetime historyOrderOpenTime;
	double historyPartialTarget;


	for( int i=0; i<amountPartialTarget; i++ ) {

		objectName = (string)_orderTicket + " target "+(string)i;
		historyPartialTarget = ObjectGet( objectName, 1 );

		//	find partial target
		if( ObjectFind( 0, objectName == 0 )	) {
			ObjectDelete( objectName );
			//	select order ticket
			//	find OrderOpenPrice and OrderOpenTime
			if( OrderSelect( _orderTicket, SELECT_BY_TICKET, MODE_HISTORY) == true && OrderSymbol() == Symbol() ) {
				historyOrderOpenPrice = OrderOpenPrice();
				historyOrderOpenTime = OrderOpenTime();
			}

			//	iterate each open positions
			//	if position has same OrderOpenTime and OrderOpenPrice
			//	change name partial target levels to new open position name
			for( int j=0; j<OrdersTotal(); j++ ) {
				if(	OrderSelect( j, SELECT_BY_POS, MODE_TRADES ) == true && OrderSymbol() == OrderSymbol() ) {
					Print("historyOrderOpenTime: ", historyOrderOpenTime);
					Print("historyOrderOpenPrice: ", historyOrderOpenPrice);
					Print("partialOrderOpenTime: ", OrderOpenTime() );
					Print("partialOrderOpenPrice: ", OrderOpenPrice() );
					if( OrderOpenTime() == historyOrderOpenTime && OrderOpenPrice() == historyOrderOpenPrice ) {
						Print("same order found");
						ObjectCreate(0,  (string)OrderTicket() + " target "+(string)i ,OBJ_HLINE, 0,0, historyPartialTarget );
						ObjectSetInteger( 0, (string)OrderTicket() + " target "+(string)i , OBJPROP_COLOR, Orange );
						ObjectSetInteger( 0, (string)OrderTicket() + " target "+(string)i , OBJPROP_STYLE, STYLE_DASH );
					}
				}
			}
		}
	}

};










