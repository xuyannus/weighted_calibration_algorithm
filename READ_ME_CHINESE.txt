我们认为可以改进的问题：
1.在estimate wh的时候，octave可能开不出那么大的矩阵，因此可能需要分批estimate
2.在设置threshold时，可以考虑使用find加速
3.我们尝试过使od仅影响后2个interval，人为删去其余weight matrix中的值，但效果不好
4.针对稀疏矩阵，marge 和 seperate 的效率不高






PS
1.利用步长比起直接挪效果差，步长很难让所有值都满足
2.没有调整rt_choice.dat,现阶段只有3个参数值，影响太过复杂
