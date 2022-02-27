/* Initial beliefs and rules */

// initially, I believe that there is some beer in the fridge
available(beer,fridge).
money_to_buy(20).

// my owner should not consume more than 10 beers a day :-)
limit(beer,5).

too_much(B) :-
   .date(YY,MM,DD) &
   .count(consumed(YY,MM,DD,_,_,_,B),QtdB) &
   limit(B,Limit) &
   QtdB > Limit.


/* Plans */

+!bring(owner,beer)
   :  available(beer,fridge) & not too_much(beer)
   <- !go_at(robot,fridge);
      open(fridge);
      get(beer);
      close(fridge);
      !go_at(robot,owner);
      hand_in(beer);
      ?has(owner,beer);
      // remember that another beer has been consumed
      .date(YY,MM,DD); .time(HH,NN,SS);
      +consumed(YY,MM,DD,HH,NN,SS,beer).

+!bring(owner,beer)
   :  not available(beer,fridge) & super_barato(S)
   <- .send(S, achieve, order(beer,3));
   .print("He realizado el pedido de cervezas a ", S);
      !go_at(robot,fridge). // go to fridge and wait there.

+!bring(owner,beer)
   :  too_much(beer) & limit(beer,L)
   <- .concat("The Department of Health does not allow me to give you more than ", L,
              " beers a day! I am very sorry about that!",M);
      .send(owner,tell,msg(M)).

-!bring(_,_)
   :  true
   <- .current_intention(I);
      .print("Failed to achieve goal '!has(_,_)'. Current intention is: ",I).

+!go_at(robot,P) : at(robot,P) <- true.
+!go_at(robot,P) : not at(robot,P)
  <- move_towards(P);
     !go_at(robot,P).

+!calcularPrecioMasBarato : true <-
.findall([X,Y], price(beer,X)[source(Y)], L);
.print("Lista de precios: ", L);
.min(L, Min);
.nth(1, Min, S);
-+super_barato(S);
.print("Super mas barato: ", S);
.nth(0, Min, P);
-+precio_barato(P);
.print("Precio mas barato: ", P).



// when the supermarket makes a delivery, try the 'has' goal again
+delivered(beer,Cantidad,_OrderId)[source(Ag)]
  :  money_to_buy(M) & precio_barato(P)
  <- +available(beer,fridge);
      -+money_to_buy(M-(P*Cantidad));
      .print("Tengo menos dinero");
      .send(Ag,tell,msg("Me ha llegado correctamente el pedido."));
     !bring(owner,beer).

// when the fridge is opened, the beer stock is perceived
// and thus the available belief is updated
+stock(beer,0)
   :  available(beer,fridge)
   <- -available(beer,fridge).
+stock(beer,N)
   :  N > 0 & not available(beer,fridge)
   <- -+available(beer,fridge).

+price(beer,N)[source(Ag)] <-
.print("Me ha llegado este precio: ", N," EU de ",Ag);
!calcularPrecioMasBarato.

+?time(T) : true
  <-  time.check(T).

