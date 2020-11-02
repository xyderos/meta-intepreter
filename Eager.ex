defmodule Eager do

  def eval_expr({:atm,nameOfAtom},_), do: {:ok,nameOfAtom}

  ##def eval_expr({:var,_},[]), do: :error

  def eval_expr({:var,nameOfVar},env) do

    case Env.lookup(nameOfVar, env) do
      nil-> :error
      {_,ret}-> {:ok,ret}
    end
  end

  def eval_expr({:cons, {:var, nameOfVar}=tupl1, {:atm, nameOfAtom}}, env) do

    case eval_expr(tupl1,env) do
      :error -> :error

      {:ok, nameOfVar} ->

    case eval_expr({:atm, nameOfAtom},env) do
      :error -> :error

      {:ok, _} -> {:ok, {nameOfVar,nameOfAtom}}
      end
    end
  end

  def eval_match(:ignore, _, env), do: {:ok, env}

  def eval_match({:atm, id}, id, env), do: {:ok, env}

  def eval_match({:var, id}, val, env) do

    case Env.lookup(id, env) do
      nil -> {:ok, Env.add(id,val,env)}

      {_, ^val} -> {:ok, env}

      {_, _} -> :fail
    end
  end

  def eval_match({:cons, {:var, _}=hp, {:atm, _}=tp}, {str1,str2},env) do

    case eval_match(hp, str1, env) do
      :fail -> :fail

      {:ok,env } -> eval_match(tp,str2,env)
    end
  end

  def eval_match(_,_,_), do: :fail

  def eval_seq([l], env), do: eval_expr(l, env)

  def eval_seq([{:match,pattern,expr}|t], env) do

    case eval_expr(expr,env) do
      :error-> :error
      {:ok, name}->
        vars=extractVars(pattern)
        env=Env.remove(vars, env)

        case eval_match(pattern,name,env) do
          :fail-> :error
          {:ok, env}-> eval_seq(t,env)
        end
    end
  end

  def extractVars(l), do: extractVars(l,[])

  defp extractVars(:ignore,l1), do: l1

  defp extractVars({:atm,_},l1), do: l1

  defp extractVars({:var, var}, l1), do: [var| l1]

  defp extractVars({:cons ,head,tail},l1), do: extractVars(tail, extractVars(head,l1))

  def eval(seq), do: eval_seq(seq,[])

end
