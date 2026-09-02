import math

def calculate_quantized_vc_bounds(total_weights: int, bit_width: int, sample_count: int) -> dict:
    """Computes the theoretical VC dimension upper bound and generalization
    error envelope for a quantized neural network architecture.
    """
    # Number of discrete states per weight configuration
    discrete_states = 2 ** bit_width

    # Effective VC dimension upper bound for discrete/quantized weight spaces
    # Scales logarithmically with the cardinality of the discrete parameter space
    if bit_width >= 32:
        # Falls back to standard continuous bound O(W log W)
        effective_vc = total_weights * math.log2(max(total_weights, 2))
    else:
        # Quantized restriction reduces shattering capacity
        effective_vc = total_weights * bit_width * 0.53

    # Generalization error delta bound (PAC-learning framework)
    confidence_delta = 0.05
    generalization_bound = math.sqrt(
        (effective_vc * (math.log(2.0 * sample_count / effective_vc, 2) + 1) + math.log(4.0 / confidence_delta)) / sample_count
    )

    return {
        "total_weights": total_weights,
        "bit_width": bit_width,
        "effective_vc_dimension": round(effective_vc, 2),
        "max_hypothesis_cardinality": discrete_states ** total_weights if total_weights < 60 else "Overflow (>2^60)",
        "generalization_error_bound": round(generalization_bound, 4)
    }

# Example execution for a compact quantized model structure
metrics = calculate_quantized_vc_bounds(total_weights=1000000, bit_width=4, sample_count=50000)
for key, val in metrics.items():
    print(f"{key}: {val}")
