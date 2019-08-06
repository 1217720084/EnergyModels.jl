struct ComponentDescription
    name::Symbol
    componenttype::Type{<:Component}
    attributes::DataFrame
end

const componentdescriptions = ComponentDescription[]

function componentdescription(name::Symbol)
    j = findfirst(cd -> cd.name == name, componentdescriptions)
    !isnothing(j) ? componentdescriptions[j] : error("Component $componentname has not been registered")
end
function componentdescription(::Type{T}) where T <: Component
    j = findfirst(cd -> T <: cd.componenttype, componentdescriptions)
    !isnothing(j) ? componentdescriptions[j] : error("Component type $T has not been registered")
end

function getdefault(c::Component, attr::Symbol)
    attrs = attributes(typeof(c))
    i = findfirst(isequal(attr), attrs.attribute)
    isnothing(i) && error("Attribute $attr for component $c is not known")
    ret = attrs.default[i]
    ismissing(ret) && error("Attribute $attr for component $c does not have a default")
    ret
end

resolve(::Type{Component}, name::Symbol) = componentdescription(name).componenttype
attributes(name) = componentdescription(name).attributes

addcomponent(cd::ComponentDescription) where T<:Component = push!(componentdescriptions, cd)
addcomponent(::Type{T}) where T<:Component = addcomponent(T, naming(T))
addcomponent(::Type{T}, name::Symbol) where T<:Component = addcomponent(ComponentDescription(name, T, DataFrame()))

function addcomponent(::Type{T}, name::Symbol, axes, filename) where T<:Component
    axes = (first(axes)=>name, Base.tail(axes)...)
    df = DataFrame(CSV.read(filename, truestrings=["t"], falsestrings=["f"]))
    df.attribute = Symbol.(df.attribute)
    df.default = map(r->astype(r.dtype, r.default), eachrow(df))
    rename_dimensions(x) = tuple(recode(Symbol.(split(x, ',')), axes...)...)
    df.dimensions = map(x->ismissing(x) ? () : rename_dimensions(x), df.dimensions)

    addcomponent(ComponentDescription(name, T, df))
end

function naming(::Type{T}) where T <: Component
    j = findfirst(cd -> cd.componenttype == T, componentdescriptions)
    !isnothing(j) && return componentdescriptions[j].name

    S = T
    while S isa UnionAll
        S = S.body
    end

    s = lowercase(string(S.name.name))
    Symbol(s, in(s[end], ('s', 'h')) ? "es" : "s")
end
