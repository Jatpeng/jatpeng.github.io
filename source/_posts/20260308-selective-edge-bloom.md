---
title: 基于 URP 的 LDR 局部边缘泛光方案 (Selective Edge Bloom)
comments: true
copyright: true
date: 2026-03-08 11:13:00
tags:
  - Unity
  - URP
  - 渲染
  - 后处理
categories:
  - 游戏开发
description: 在 URP 环境下实现不依赖 HDR 的局部边缘泛光，包含深度与遮挡控制
cover: https://picsum.photos/seed/20260308-selective-edge-bloom/1200/675
---

## 1. 概述 (Overview)

本方案旨在 Unity Universal Render Pipeline (URP) 环境下，实现一种不依赖高动态范围（HDR）与全局后处理的局部边缘泛光效果。特别适用于需要保留模型本身贴图细节、仅在物体边缘产生溢色光晕，且严格要求物理遮挡关系正确的场景（如复杂的室内环境、角色背着发光武器等）。

### 1.1 解决的核心痛点

- **绕过 LDR 限制**：无需全屏亮度阈值提取
- **保护材质细节**：利用反向遮罩剔除中心过曝，保留模型原有光照
- **解决透视穿模（X-Ray 穿透）**：通过复用主相机深度缓冲（Depth Buffer），确保发光体在被其他物体遮挡时，光晕表现符合物理逻辑

---

## 2. 渲染管线架构 (Pipeline Architecture)

本方案通过自定义 URP ScriptableRendererFeature 注入三个核心 Render Pass：


| Pass           | 注入时机                  | 职责        |
| -------------- | --------------------- | --------- |
| Mask Pass      | AfterRenderingOpaques | 提取目标物体遮罩  |
| Blur Pass      | AfterMaskPass         | 降采样与升采样模糊 |
| Composite Pass | AfterPostProcessing   | 边缘提取与最终合成 |


**整体数据流：**

```
场景深度图 → [Mask Pass] → RT_Mask (遮挡关系正确)
                ↓
         [Blur Pass] → RT_Bloom (模糊光晕)
                ↓
         [Composite Pass] → 最终画面
```

---

## 3. 核心实现步骤 (Implementation Details)

### 3.1 步骤一：生成纯色遮罩 RT 与深度绑定

**目标：** 将发光物体单独隔离到一张 Render Texture 上，同时必须尊重场景已有的遮挡关系。

**注入时机：** `RenderPassEvent.AfterRenderingOpaques`（不透明物体渲染完成后）

**操作步骤：**

1. 申请一张黑色底色的临时 `RT_Mask` 作为 Color Target
2. 在 ConfigureTarget 阶段，将 Depth Target 强制绑定为主相机的深度图 (`renderer.cameraDepthTarget`)
3. 使用 Unlit 纯色 Shader 绘制目标模型
4. 设置深度测试：ZWrite = Off，ZTest = LEqual

**核心代码示意：**

```csharp
// 配置 Render Target
configuringCommand.SetRenderTarget(
    colorTarget, 
    RenderBufferLoadAction.DontCare, 
    RenderBufferStoreAction.Store,
    depthTarget,  // 绑定主相机深度
    RenderBufferLoadAction.DontCare, 
    RenderBufferStoreAction.Store
);

// 设置深度测试
configuringCommand.SetRenderDepthState(
    DepthStencilState.depthStateWithDepthTest,
    (int)CompareFunction.LessEqual
);
```

**结果：** 当发光剑被墙壁遮挡时，墙壁背后的剑体像素会因为未通过深度测试而被剔除。

### 3.2 遮挡视觉表现的分歧点控制

通过调整深度测试逻辑，可以实现两种截然不同的美术效果：

#### 风格 A：严格物理断开（硬遮挡）

- **设置：** ZTest = LEqual（默认）
- **表现：** 发光体被遮挡的部分完全不产生 Mask，光晕在遮挡物边缘戛然而止
- **适用场景：** 写实类发光（如普通霓虹灯管）

#### 风格 B：高能体积溢光（Light Bleeding）

- **设置：** ZTest = Always，或注入时机提前到 BeforeRenderingOpaques
- **表现：** 完整剑体依然画入 RT_Mask，强光"溢出"覆盖遮挡物边缘
- **适用场景：** 魔法武器或高热等离子体

### 3.3 步骤二：泛光模糊处理

**目标：** 对正确处理了遮挡关系的 RT_Mask 进行物理扩散。

**操作：** 

- Dual Kawase Blur 或 Gaussian Blur
- 逐级 Downsample 与 Upsample 混合
- 输出 RT_Bloom

### 3.4 步骤三：边缘提取与最终合成

**目标：** 剔除光晕中心，仅保留边缘发光，并叠加回主场景。

**公式：**

```hlsl
// 边缘提取：剔除中心，保留边缘
float4 RT_Edge = RT_Bloom * (1.0 - RT_Mask);

// 最终合成：加法混合
float4 RT_Final = RT_Scene + RT_Edge;
```

---

## 4. 性能优化建议


| 优化项       | 建议                          |
| --------- | --------------------------- |
| RT 分辨率    | 强制使用 1/2 或 1/4 屏幕分辨率        |
| RT 格式     | ARGB32 低精度，避免 FP16          |
| LayerMask | 仅针对发光物体 Layer（如 GlowWeapon） |
| Culling   | 复用主相机 Culling 结果            |


---

## 5. 总结

本方案通过三个精心设计的 Render Pass，实现了：

1. ✅ 不依赖 HDR 的边缘泛光
2. ✅ 保留模型材质细节
3. ✅ 物理正确的遮挡关系
4. ✅ 两种美术风格可选

适用于 URP 项目的局部发光特效需求，尤其是对遮挡关系要求严格的场景。