struct MOIElement{I <: Integer, F <: Function, T <: Union{Nothing, Number}} <:
       MOI.AbstractVectorSet
    id::I
    op::F
    val::T
    dimension::Int

    function MOIElement(id, op, val, dim = 0)
        return new{typeof(id), typeof(op), typeof(val)}(id, op, val, dim)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOIElement{I, F, T}},) where {
        I <: Integer, F <: Function, T <: Union{Nothing, Number},}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOIElement,)
    id = iszero(set.id) ? nothing : set.id
    function c(x; kwargs...)
        new_kwargs = merge(kwargs, Dict(:id => id, :op => set.op, :val => set.val))
        return concept(USUAL_CONSTRAINTS[:element])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV, MOIElement{typeof(set.id), typeof(set.op), typeof(set.val)}}(cidx)
end

function Base.copy(set::MOIElement)
    val = set.val === nothing ? nothing : copy(set.val)
    return MOIElement(copy(set.id), set.op, val, copy(set.dimension))
end

struct Element{I <: Integer, F <: Function, T <: Union{Nothing, Number}} <:
       JuMP.AbstractVectorSet
    id::I
    op::F
    val::T

    function Element(; id::I = 0, op::F = ==,
            val::T = 0,) where {I <: Integer, F <: Function, T <: Union{Nothing, Number}}
        return new{typeof(id), typeof(op), typeof(val)}(id, op, val)
    end
end

function JuMP.moi_set(set::Element, dim_moi::Int)
    return MOIElement(set.id, set.op, set.val, dim_moi)
end
