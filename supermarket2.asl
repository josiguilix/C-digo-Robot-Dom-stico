last_order_id(1). // initial belief
price(beer,4).
money(20).

!tell_price.

// plan to achieve the goal "order" for agent Ag

+!tell_price : price(beer, Precio) <-
.send(robot,tell,price(beer,Precio)).

+!order(Product,Qtd)[source(Ag)] : money(M) & price(beer, P)
  <- ?last_order_id(N);
     OrderId = N + 1;
     -+last_order_id(OrderId);
     deliver(Product,Qtd);
     -+money(M+(P*Qtd));
     .print("Tengo mas dinero"); 
     .send(Ag, tell, delivered(Product,Qtd,OrderId)).


+msg(M)[source(Ag)] : true
   <- .print("He recibido este mensaje de ",Ag,": ",M);
      -msg(M).

