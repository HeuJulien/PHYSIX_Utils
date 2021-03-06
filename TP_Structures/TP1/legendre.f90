real(8) function legendre(l,x)
! Legendre polynomial
implicit none
integer :: l, k
real(8) :: x, p, pp, pm
pm = 1._8 ! 1st terms
p = x
if ( l==0 ) then ; legendre = pm
elseif( l==1) then ; legendre = p
else
 do k = 2, l ! reccurence
   pp = ((2*k-1)*x*p-(k-1)*pm)/k
   pm = p ; p = pp
 enddo
 legendre = p
endif

end function legendre


real(8) recursive function assoc_legendre(l,m,x) result(plm)
! Associated Legendre polynomial
implicit none
integer :: k, l, m, p, dblfact
real(8) :: x, r, legendre
if ( m > l ) stop 'l>m'
if ( abs(x) > 1._8 ) stop '|x| > 1.'
r = sqrt(1._8-x**2)
if ( l == 0 ) then ; plm = 1._8
else if ( l == 1 ) then
  if ( m == 0 ) then ; plm = x
  else ; plm = -r
  endif
else
  if ( m == l ) then
    p = dblfact(2*l-1)
    if ( mod(l,2) == 0 ) then ; plm = p*r**l
    else ; plm = -p*r**l
    endif
  else 
    plm = legendre(l,x)
    if ( m /= 0 ) then
      do k = 1, m
        p = k-1
        plm = ((l-p)*x*plm - (l+p)*assoc_legendre(l-1,p,x))/r
      enddo
    endif
  endif
endif
end function assoc_legendre


integer function dblfact(l) result(k)
! Double factorial
implicit none
integer :: l, m
k  = 1.
if ( l > 0 ) then
  do m = l, 1, -2
    k = k*m
  enddo
endif
end function dblfact
