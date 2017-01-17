Creating the Postgresql databases for Ergane Import
---------------------------------------------------

Unfortunately this is not automated, because it requires permissions
that the account for building FreeDict doesn't have.

> su
> sudo -u postgres createuser $USER
   superuser right - no
   create db right - yes
   create roles right - no
> exit
> createdb



