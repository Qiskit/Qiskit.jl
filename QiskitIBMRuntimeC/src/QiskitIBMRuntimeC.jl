# This code is part of Qiskit.
#
# (C) Copyright IBM 2026.
#
# This code is licensed under the Apache License, Version 2.0. You may
# obtain a copy of this license in the LICENSE.txt file in the root directory
# of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
#
# Any modifications or derivative works of this code must retain this
# copyright notice, and modified files need to carry a notice indicating
# that they have been altered from the originals.

module QiskitIBMRuntimeC

libdir = joinpath(@__DIR__, "..", "lib")
include(joinpath(libdir, "LibQiskitIBMRuntime.jl"))

using qiskit_ibm_runtime_jll

libqkrt = qiskit_ibm_runtime_jll.libqiskit_ibm_runtime

using Compat
using Qiskit
using Qiskit.C

using .LibQiskitIBMRuntime
import .LibQiskitIBMRuntime: Service as QkrtService, Job as QkrtJob, Backend as QkrtBackend, BackendSearchResults as QkrtBackendSearchResults, Samples as QkrtSamples

using CEnum: CEnum, @cenum
import Dates

function check_exit_code(code::Integer)::Nothing
    if code != 0
        throw(ErrorException("Non-zero exit code: $(code)"))
    end
end

"""
    Service

This type represents an instance of the Qiskit IBM Runtime service.

"""
mutable struct Service
    ptr::Ptr{QkrtService}

    @doc"""
        Service()

    This constructor reads credentials from the file `\$HOME/.qiskit/qiskit-ibm.json`.

    In the future, this constructor may also support passing credentials via
    environment variables, but at the time of writing, this is not yet supported by
    qiskit-ibm-runtime-c.
    """
    function Service()
        service = Ref{Ptr{QkrtService}}(C_NULL)
        code = qkrt_service_new(service)
        check_exit_code(code)
        retval = new(service[])
        finalizer(qkrt_service_free, retval)
        retval
    end
end

LibQiskitIBMRuntime.qkrt_service_free(service::Service) =
    qkrt_service_free(service.ptr)

"""
    Backend

This type represents a quantum hardware backend.
"""
mutable struct Backend
    ptr::Ptr{QkrtBackend}
    # We hold a reference to the search results so they don't get freed while
    # this exists
    search_results::Any # Any because we can't reference BackendSearchResults yet on this line
end

"""
    BackendSearchResults <: AbstractVector{Backend}

This type contains the results of a backend search.
"""
mutable struct BackendSearchResults <: AbstractVector{Backend}
    ptr::Ptr{QkrtBackendSearchResults}
    function BackendSearchResults(ptr::Ptr{QkrtBackendSearchResults})
        retval = new(ptr)
        finalizer(qkrt_backend_search_results_free, retval)
        retval
    end
end

LibQiskitIBMRuntime.qkrt_backend_search_results_free(sresults::BackendSearchResults) =
    qkrt_backend_search_results_free(sresults.ptr)

"""
    backend_search(service)

Obtain knowledge of the backends available for the given `service`, in the
form of a `BackendSearchResults` object.
"""
function backend_search(service::Service)
    sresults = Ref{Ptr{QkrtBackendSearchResults}}(C_NULL)
    GC.@preserve service check_exit_code(LibQiskitIBMRuntime.qkrt_backend_search(sresults, service.ptr))
    BackendSearchResults(sresults[])
end

"""
    least_busy(::BackendSearchResults)

Return the `Backend` which is least busy at the time of the backend search.

Available properties:

- `name`
- `instance_name`
- `instance_crn`
"""
function least_busy(obj::BackendSearchResults)::Backend
    backend = qkrt_backend_search_results_least_busy(obj.ptr)
    Backend(backend, obj)
end

Base.IndexStyle(::Type{BackendSearchResults}) = IndexLinear()
Base.size(sresults::BackendSearchResults) =
    (qkrt_backend_search_results_length(sresults.ptr),)

function Base.getindex(sresults::BackendSearchResults, i::Integer)::Backend
    @boundscheck checkbounds(sresults, i)
    ptr = unsafe_load(qkrt_backend_search_results_data(sresults.ptr), i)
    Backend(ptr, sresults)
end

function Base.iterate(sresults::BackendSearchResults)
    if isempty(sresults)
        return nothing
    else
        i = firstindex(sresults)
        return (sresults[i], i + 1)
    end
end

function Base.iterate(sresults::BackendSearchResults, state)
    if state > length(sresults)
        return nothing
    else
        return (sresults[state], state + 1)
    end
end

function Base.propertynames(backend::Backend; private::Bool = false)
    union(fieldnames(typeof(obj)), (:name, :instance_crn, :instance_name))
end

function from_cstring_and_free(str::Ptr{Cchar})
    retval = unsafe_string(str)
    qkrt_str_free(str)
    retval
end

function Base.getproperty(backend::Backend, sym::Symbol)
    if sym === :name
        return GC.@preserve backend unsafe_string(qkrt_backend_name(backend.ptr))
    elseif sym === :instance_crn
        return unsafe_string(qkrt_backend_crn_name(backend.ptr))
    elseif sym === :instance_name
        return unsafe_string(qkrt_backend_instance_name(backend.ptr))
    else
        return getfield(backend, sym)
    end
end

function Base.show(io::IO, ::MIME"text/plain", backend::Backend)
    print(io, "Backend(<", backend.name, ">)")
end

"""
    target_from_backend(backend, service)

Construct a `Qiskit.Target` which is appropriate for the provided `Backend`.
"""
function target_from_backend(backend::Backend, service::Service)::Qiskit.Target
    @assert service.ptr !== C_NULL
    @assert backend.ptr !== C_NULL
    GC.@preserve service backend begin
        target = qkrt_get_backend_target(service.ptr, backend.ptr)
    end
    if target === C_NULL
        throw(ErrorException("Null pointer obtained instead of target"))
    end
    Qiskit.Target(target)
end

"""
    Job

Qiskit IBM Runtime job.
"""
mutable struct Job
    ptr::Ptr{QkrtJob}
    function Job(ptr::Ptr{QkrtJob})
        retval = new(ptr)
        finalizer(qkrt_job_free, retval)
        retval
    end
end

LibQiskitIBMRuntime.qkrt_job_free(job::Job) =
    qkrt_job_free(job.ptr)

"""
    run_sampler_job(service, backend, circuit, shots::Integer)

Submit a job to the sampler primitive.

The provided `circuit` must have "measure" instructions in order for its result to be useful.
"""
function run_sampler_job(service::Service, backend::Backend, circuit::QuantumCircuit, shots::Integer)
    job_ptr = Ref{Ptr{QkrtJob}}(C_NULL)
    check_exit_code(qkrt_sampler_job_run(job_ptr, service.ptr, backend.ptr, circuit.ptr, shots, C_NULL))
    return Job(job_ptr[])
end

"""
    Samples <: AbstractVector{String}

Data type which stores samples returned from the quantum computer.
"""
mutable struct Samples <: AbstractVector{String}
    ptr::Ptr{QkrtSamples}
    function Samples(ptr::Ptr{QkrtSamples})
        retval = new(ptr)
        finalizer(qkrt_samples_free, retval)
        retval
    end
end

LibQiskitIBMRuntime.qkrt_samples_free(samples::Samples) =
    qkrt_samples_free(samples.ptr)

Base.IndexStyle(::Type{Samples}) = IndexLinear()
Base.size(samples::Samples) = (Int(qkrt_samples_num_samples(samples.ptr)),)

function Base.getindex(samples::Samples, i::Integer)
    @boundscheck checkbounds(samples, i)
    cstr = qkrt_samples_get_sample(samples.ptr, i - 1)
    from_cstring_and_free(cstr)
end

function Base.iterate(samples::Samples)
    if isempty(samples)
        return nothing
    else
        i = firstindex(samples)
        return (samples[i], i + 1)
    end
end

function Base.iterate(samples::Samples, state)
    if state > length(samples)
        return nothing
    else
        return (samples[state], state + 1)
    end
end

"""
    JobStatus

Enum which represents the status of a job.
"""
@cenum JobStatus::UInt32 begin
    Queued = 0
    Running = 1
    Completed = 2
    Cancelled = 3
    CancelledRanTooLong = 4
    Failed = 5
end

"""
    get_job_status(job, service)

Return status of job as a `JobStatus` enum.
"""
function get_job_status(job::Job, service::Service)::JobStatus
    status = Ref{UInt32}(0)
    check_exit_code(qkrt_job_status(status, service.ptr, job.ptr))
    JobStatus(status[])
end

"""
    get_job_results(job, service; poll_interval=1)

Return job results as a `Samples` object.  The `poll_interval` argument can be
any type accepted by `sleep()`.  By default, it will poll every second while in
the `Queued` or `Running` state.  To disable polling entirely and error if the
job is not `Completed`, pass `poll_interval=nothing`.
"""
function get_job_results(job::Job, service::Service; poll_interval::Union{Real,Dates.Period,Nothing}=Dates.Second(1))
    # First make sure (or wait until) the job is actually complete
    status = get_job_status(job, service)
    if poll_interval !== nothing
        while status == Queued || status == Running
            sleep(poll_interval)
            status = get_job_status(job, service)
        end
    end
    if status != Completed
        throw(ErrorException("Cannot get results of job with status $status"))
    end
    # Now obtain the results
    samples = Ref{Ptr{QkrtSamples}}(0)
    check_exit_code(qkrt_job_results(samples, service.ptr, job.ptr))
    Samples(samples[])
end

export Service, Backend, BackendSearchResults, JobStatus
@compat public Job, Samples
export least_busy, backend_search, run_sampler_job, get_job_status, get_job_results, target_from_backend

# Export (or at least make public) enum instances
for e in (JobStatus,)
    for s in instances(e)
        @eval @compat public $(Symbol(s))
    end
end

end # module QiskitIBMRuntimeC
