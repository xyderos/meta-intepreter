defmodule Env do

  def new(), do: []

  def add(var,exp,env), do: [{var,exp}|env]

  def lookup(var,[{var, _}=h|_]), do: h

  def lookup(var,[{_, _}|t]), do: lookup(var,t)

  def lookup(_,[]), do: nil

  def remove(_,[]), do: []

  def remove(var,[{var,_}|t]), do: remove(var,t)

  def remove(var,[{_,_}=val|t]), do: [val|remove(var,t)]

end
