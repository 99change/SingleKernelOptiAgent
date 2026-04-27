"""
profiler.py
对 CUDA kernel 进行基准性能测评，获取基准时间。
支持真实 GPU 运行和 mock 模式（无 GPU 时使用）。
纯工具流，不调用 LLM。瓶颈分析由 AnalyzerAgent 负责。
"""

import logging

from core.models import ProfileResult, KernelMetrics
from core.config import SYS_CONFIG
from tools.kernel_tools import compile_cuda, run_compiled_kernel, mock_profile


class ProfilerAgent:

    def __init__(self, mock_mode: bool = None):
        self.logger = logging.getLogger("Agent.ProfilerAgent")
        # mock_mode 优先级：参数 > SYS_CONFIG > False
        if mock_mode is None:
            mock_mode = SYS_CONFIG.mock_profiling
        self.mock_mode = mock_mode

    def execute(self, kernel_code: str) -> ProfileResult:
        self.logger.info(f"Profiling kernel (mock_mode={self.mock_mode})...")

        if self.mock_mode:
            test_result = mock_profile(kernel_code)
        else:
            # 真实编译 + 运行
            compile_result = compile_cuda(kernel_code)
            if not compile_result.success:
                self.logger.warning(
                    f"Compilation failed, falling back to mock profiling.\n"
                    f"Error: {compile_result.error}"
                )
                test_result = mock_profile(kernel_code)
            else:
                test_result = run_compiled_kernel(compile_result.binary_path)

        avg_time = test_result.exec_time_ms if test_result.success else 0.0

        self.logger.info(f"Baseline time: {avg_time:.2f} ms")

        return ProfileResult(
            metrics=test_result.metrics or KernelMetrics(exec_time_ms=avg_time),
            baseline_time_ms=avg_time,
        )
