module Intervalosa

import Base.exp
import Base.log
import Base.cos
import Base.sin
export Intervalo, +,-,*,/, ==, ∈, ⊂, ^, UnionI, RUP, RDOWN ,exp, eva, round!, log, grafica, norm, cos, Intrsc, vacio, bisectar

##########################
######  tipos ############
#### intervalo y #########
###unión de intervalos####
##########################

type Intervalo
    a::BigFloat
    b::BigFloat
	function Intervalo(x,y)
    if y<x
      a=y
      b=x
		else
      a=x
      b=y
		end
	new(a,b)
	end
end


type UnionI
p::Intervalo
s::Intervalo  
end
type vacio
  y
end
##################3
###PARA EVALUAR###
##DERIVADAS#####
############





function Intrsc(x::Intervalo, y::Intervalo)
#seis casos en total
##primero ver si es el conjunto vacío
  if x.b<y.a || y.b<x.a #dos casos
       ans=vacio(0)
  elseif x.b>= y.a #dos casos
    d=max(y.a, x.a)
    u=min(x.b, y.b)
        ans= Intervalo(u, d)
  elseif y.b>= x.a
      d=max(y.a, x.a)
      u=min(y.b, x.b)
        ans=Intervalo(u, d)
        end
    ans
end

Intrsc(U::UnionI, y::Intervalo)=UnionI(Intrsc(U.p,y), Intrsc(U.s, y))



Intrsc(y::Intervalo, U::UnionI)=UnionI(Intrsc(U.p,y), Intrsc(U.s, y))


function bisectar(x::Intervalo, n::Integer) 
    b=x.a+(x.b-x.a)/2
    if n==1
        Intervalo(x.a,b)
    elseif n==2
        Intervalo(b, x.b)
    else 
        return error
        
    end
end



#una constante o intervalo constante
function Intervalo(c)
    Intervalo(c,c)
end
####################
####################
####  REDONDEOS ####
##################

function round!(i::Intervalo)   #aún no se si este es necesario
    set_rounding(BigFloat, RoundDown)
    i.a=BigFloat(i.a)
    set_rounding(BigFloat, RoundUp)
    i.b=BigFloat(i.b)
    i
end

### para realizar funciones con  redondeo  HACIA ARRIBA (funciones de un solo argumento, como exp, *, cos)
function RUP(g::Function, x)  #redondeo hacia arriba
	set_rounding(BigFloat, RoundUp)
	g(BigFloat(x))
end


###HACIA ABAJO

function RDOWN(g::Function, x) ##redonde hacia abajo
	set_rounding(BigFloat, RoundDown)
	g(BigFloat(x))
end

#para funciones que requieren dos argumentos como ^, log
function RUP(g::Function, x, y)  #redondeo hacia arriba
	set_rounding(BigFloat, RoundUp)
	g(BigFloat(x), BigFloat (y))
end


function RDOWN(g::Function, x, y) ##redonde hacia abajo
	set_rounding(BigFloat, RoundDown)
	g(BigFloat(x),BigFloat (y))
end



##########################
##########################
######### SUMA  ##########
##########################
##########################

+(x::Intervalo, y::Intervalo)=Intervalo(RDOWN(+,x.a, y.a), RUP(+,x.b,y.b))

+(x::Intervalo, y::Real)=x+Intervalo(y)

+(x::Real, y::Intervalo)= Intervalo(x)+y


##########################
##########################
######### RESTA ##########
##########################
##########################

-(x::Intervalo, y::Intervalo)=Intervalo(RDOWN(-,x.a, y.b), RUP(-,x.b,y.a))

-(x::Intervalo, y::Real)=x-Intervalo(y)

-(x::Real, y::Intervalo)= Intervalo(x)-y

-(x::Intervalo, U::UnionI)=UnionI(x-U.p, x-U.s)

-( U::UnionI, x::Intervalo)=UnionI(U.p-x, U.s-x)


##########################
##########################
##### MULTIPLICACION #####
##########################
##########################


function *(x::Intervalo, y::Intervalo)
set_rounding(BigFloat, RoundDown)
d=min(x.a*y.b,x.b*y.a, x.a*y.a, x.b*y.b)
set_rounding(BigFloat, RoundUp)
u= max(x.a*y.b,x.b*y.a, x.a*y.a, x.b*y.b)
Intervalo(d,u)
end


*(x::Intervalo, c::Real)=Intervalo(c)*x

*(c::Real, x::Intervalo)=Intervalo(c*x.a, c*x.b)

*(x::Intervalo, u::UnionI)=UnionI(x*u.p, x*u.s)



##########################
##########################
######## DIVISION ########
##########################
##########################

function /(x::Intervalo, y::Intervalo)#la division se define en terminos de la multiplicacion y depende de si el intervalo divisor contiene al cero
	if  ∈(0.0, y) == true
		x*UnionI(Intervalo(-Inf,1/y.a ), Intervalo(1/y.b, Inf))
	else
		    Intervalo(x.a,x.b)*Intervalo(1/y.a, 1/y.b)
    	end
end

/(x::Intervalo, y::Real)=Intervalo(x.a,x.b)*Intervalo(1/y)


/(x::Real, y::Intervalo)= Intervalo(x)*Intervalo(1/y.a, 1/y.b)



##########################
##########################
####### POTENCIAS ########
##########################
##########################

function mig(x::Intervalo)
		if ∈(0.0, x) == true
			return 0
		else return min(abs(x.a), abs(x.b))
		end
	end


mag(x::Intervalo) = max(abs(x.a), abs(x.b))

#condiciones de redondeo


function ^(x::Intervalo, n::Integer)
     if (x.a > 0 && x.b > 0)
        return Intervalo(x.a^n,x.b^n)
     elseif (x.b < 0 && x.a < 0)
         return Intervalo(x.b^n,x.a^n)
     else
        return Intervalo(0,max(x.a^n,x.b^n))
    end
end




^(x::Intervalo, n::Real)=eva(^, x,n)


#algunas funciones monótonas

exp(x::Intervalo)=eva(exp, x)


function log(n::Real,x::Intervalo)
	set_rounding(Float64, RoundDown)
	d=log(n ,float64(x.a))
	set_rounding(Float64, RoundUp)
	u=log(n ,float64(x.b))
	round!(Intervalo(d,u))
end

##########################
##########################
######## funciones #######
#### trigonometricas #####
##########################
function cos(x::Intervalo)
  d=x.a%2*π
  u=x.b%2*π
if norm(x)>2*π
    Intervalo(-1,1)
  elseif d<=π&& u<=π
    eva(cos, x)
  elseif d<=π u>=π
    Intervalo(-1, RUP(d))



  end
end



##########################
##########################
######## IGUALDAD ########
##########################
##########################



function ==(x::Intervalo, y::Intervalo)
    if x.a==y.a&&x.b==y.b
        true
    else
        false
    end
end


function ==(x::UnionI, y::UnionI)
    if (x.s==y.s || x.s==y.p)&&(x.p==y.s || x.p==y.p)
        true
    else
        false
    end
end

function ==(v::vacio, u::vacio)
true
end



##########################
##########################
##### PERTENENCIA ########
######## DE UN ###########
######### PUNTO###########
##########################
##########################


function ∈(c::Real,x::Intervalo)
   if x.a<=c&&c<=x.b
       return true
   else
        return false
   end

end

function ∈(c::Real,x::UnionI)
   if ∈ (c,x.s) ==true|| ∈(c,x.p)==true
       return true
   else
        return false
   end

end

function ⊂(x::Intervalo, y::Intervalo)
	if y.a<x.a&&x.b<y.b
     	 	true
 	elseif y.a==x.a&&x.b==y.b
		true
	else
		false
	end
end


########################
###### longitud ########
####### de   un ############
#######  intervalo  ####
########################
function norm(x::Intervalo)
  abs(x.b-x.a)
end

function norm(v::vacio)
return error
end

norm(U::UnionI)= max(norm(U.p), norm(U.s))

##########################
##########################
####### funciones ########
####### monotonas ########
##########################
##########################


###lo siguiente es para aplicar con funciones monótonas en general, sin embargo no es muy cómodo a la hora de usar.
function eva(f::Function, I::Intervalo)
e=f(I.a)
c=f(I.b) # esta primera parte solo la realizo para ver cual es menor y cual es mayor y entonces proceder con el redondeo hacia arriba y hacia abajo como corresponde
	if e<c  #ES CRECIENTE
	  Intervalo(RDOWN(f, I.a), RUP(f, I.b))
	elseif c<e  #ES DECRECIENTE
	  Intervalo(RDOWN(f, I.b), RUP(f, I.a))
	else  #IGUAL
	  Intervalo(RDOWN(f, I.b), RUP(f, I.a))
	end
end



# eva para funciones de dos argumentos, un intervalo y un número
function eva(f::Function, I::Intervalo, n)
e=f(I.a, n)
c=f(I.b, n) # esta primera parte solo la realizo para ver cual es menor y cual es mayor y entonces proceder con el redondeo hacia arriba y hacia abajo como corresponde
	if e<c  #ES CRECIENTE
		Intervalo(RDOWN(f, I.a, n), RUP(f, I.b, n))
	elseif c<e  #ES DECRECIENTE
		Intervalo(RDOWN(f, I.b, n), RUP(f, I.a, n))
	else  #IGUAL
	Intervalo(RDOWN(f, I.b, n), RUP(f, I.a, n))
	end
end

using PyPlot
function  grafica(a, b, f::Function)
x = [a-2:0.1:b+2];
y= zeros(length(x))
for  i = 1: length(x)
    y[i]=f(x[i])
end

    Inty=f(Intervalo(a,b))
    plot(x,y, "-", color="purple")
    PyPlot.fill_between([a,b],float64(Inty.a),float64(Inty.b),color="blue")
    PyPlot.fill_between([a-2, a],float64(Inty.a),float64(Inty.b),color="magenta", alpha=0.5)
    PyPlot.fill_between([a, b],-10, f(b), color="purple", alpha=0.5)
    end

####estaría muy bonito arreglar esto para que aparezca chido, buscar en #particulas de ejemplos
#import Base.show
#show(IO,Intervalo)
#show(io, x::Intervalo) = print(io, " [$x.a, $x.b])")

end###end del modulo






