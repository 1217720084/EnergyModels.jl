const ElementType = Type{<:Element}
struct ElementAttributes
    elemtype::ElementType
    attributes::DataFrame
end

const elemtypenames = Dict{ElementType,Symbol}()
const elements = Dict{Symbol,ElementAttributes}()

resolve(elemtypename::Symbol) = elements[elemtypename].elemtype
attributes(elemtypename::Symbol) = elements[elemtypename].attributes

addelement(::Type{T}) where T<:Element = addelement(T, naming(T))
addelement(::Type{T}, name::Symbol) where T<:Element = addelement(T, name, ElementAttributes(T, DataFrame()))
addelement(::Type{T}, name::Symbol, eq::ElementAttributes) where T<:Element =
    (elements[name] = eq; elemtypenames[T] = name)

function addelement(::Type{T}, name::Symbol, axes, filename) where T<:Element
    axes = (first(axes)=>name, Base.tail(axes)...)
    df = CSV.read(filename, truestrings=["t"], falsestrings=["f"])
    df[:attribute] = Symbol.(df[:attribute])
    df[:default] = map(r->astype(r[:dtype], r[:default]), eachrow(df))
    rename_dimensions(x) = tuple(recode(Symbol.(split(x, ',')), axes...)...)
    df[:dimensions] = map(x->ismissing(x) ? () : rename_dimensions(x), df[:dimensions])

    addelement(T, name, ElementAttributes(T, df))
end

function naming(T::ElementType)
    haskey(elemtypenames, T) && return elemtypenames[T]
    s = lowercase(string(T.name.name))
    Symbol(s, in(s[end], ('s', 'h')) ? "es" : "s")
end
