abstract type AbstractContainerView{T} <: Container end

struct ContainerView{T} <: AbstractContainerView{T}
    model::EnergyModel
    components::Dict{Symbol,T}
end

struct SubContainerView{T} <: AbstractContainerView{T}
    model::EnergyModel
    components::Dict{Symbol,T}
    buses::Axis
end

tupleaxisvals(c::Bus, A) = A.val
tupleaxisvals(c) = tupleaxisvals(c, axis(c))
tupleaxisvals(c, A) = AxisArrays.CategoricalVector(tuple.(c.class, A.val))

_maybesubset(cv::ContainerView, c, A) = A
_maybesubset(cv::SubContainerView, e::ModelElement, A) = A[indicesinbuses(e, cv.buses), ntuple(i->:,ndims(A)-1)...]

_viewaxis(cv::AbstractContainerView{T}, a) where T = Axis{Symbol(naming(T))}(a)
axis(cv::AbstractContainerView) = _viewaxis(cv, vcat((_maybesubset(cv, c, tupleaxisvals(c)) for c = components(cv))...))

Base.cat(cv::AbstractContainerView, cs::Vector{<:ModelElement}, as::Vector) = @consense(as, "Single values do not agree")
function Base.cat(cv::AbstractContainerView, cs::Vector{<:ModelElement}, as::Vector{<:AxisArray})
    _viewaxisarray(c, a) = AxisArray(a, _viewaxis(cv, tupleaxisvals(c, first(axes(a)))))
    cat(1, (_viewaxisarray(c, _maybesubset(cv, c, a)) for (c, a) = zip(cs, as))...)
end

mapcat(f::Function, cv::AbstractContainerView) = cat(cv, collect(components(cv)), map(f, components(cv)))

Base.getindex(cv::AbstractContainerView, i) = mapcat(c->c[i], cv)
Base.getindex(cv::AbstractContainerView, i::Symbol) = mapcat(c->c[i], cv)
