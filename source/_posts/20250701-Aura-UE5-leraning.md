---
title: 20250701-Aura UE5 leraning
cover: https://picsum.photos/800/600
comments: true
copyright: true
typora-root-url: ..
date: 2025-07-01 17:08:14
tags:
categories:
description:
---

# 1 .Create  project

项目设置

![image-20250701171016760](/images/20250701-Aura-UE5-leraning/image-20250701171016760.png)

![image-20250701171047721](/images/20250701-Aura-UE5-leraning/image-20250701171047721.png)

![image-20250701172653793](/images/20250701-Aura-UE5-leraning/image-20250701172653793.png)


# 2.类
AuraCharacter.cpp
TObjectptr ？
c++ 类
AuraCharacterBase  锁有Character的基类，创建了一个Wepon的骨骼网格组件，同时声明了Weapon 挂接点

AuraCharacter Class 主角类
AuraEnemy class  敌人类的父类，继承与AuraCharacter



蓝图

BP_Aura_Character 
ABP_Aura_Character

ABP_Enemy 敌人动画蓝图模板基类，不需要指定骨骼。不同敌人复用里面的动画播放速度计算逻辑
ABP_Goblin_SlingShot  设置指定敌人持有SlingShot的动画
ABP_Goblin_Spear    设置敌人持有Spear的动画


# 3.增强输入
https://dev.epicgames.com/documentation/zh-cn/unreal-engine/configure-character-movement-with-cplusplus-in-unreal-engine?application_version=5.6


Aura.Build.cs 中添加EnhancedInput模块

input Action IA_Move :设置输入的值类型，是float bool vector2,3 ?  

input map context :IMC_  设置IA_Move 中的按键，AwSD，和对应的按键的modifiy

Swizzle input Axis Values:


## 1.AuraPlayerController class

获取EnhanceInput system 将创建号IMC 添加到Enhance Input系统中

输入函数:
SetupInputComponent() 
为了实现输入和WSAD后，游戏有相应，需要一个IA_Move触发后的响应函数 Move
通过增强输入组件，来控制IA_Move 和Move 响应函数的绑定

EnhancedInputComponent->BindAction(MoveAction,ETriggerEvent::Triggered,this,&AAuraPlayerController::Move);

响应函数:

Move()
将输入的IA_Move 输入，转为角色移动的位置

```c++
void AAuraPlayerController::Move(const FInputActionValue& InputActionValue)
{
	const FVector2D InputAxisVector = InputActionValue.Get<FVector2D>();//获取MoveAction 输入xY 两个方向的值
	
	const FRotator Rotation = GetControlRotation();//控制器的选装矩阵
	const FRotator YawRotation(0.f,Rotation.Yaw,0.f);// 将控制器，俯仰角pitch，旋转角Roll,保存为0，保留偏航角Yaw。 

	const FVector ForwardDirection = FRotationMatrix(YawRotation).GetUnitAxis(EAxis::X);// 根据偏航角,获取相机当前热forward 方向
	const FVector  RightDirection = FRotationMatrix(YawRotation).GetUnitAxis(EAxis::Y); // right 方向

	if (APawn* ControlledPawn = GetPawn<APawn>())
	{
		ControlledPawn->AddMovementInput(ForwardDirection,InputAxisVector.Y); 
		ControlledPawn->AddMovementInput(RightDirection,InputAxisVector.X);
	}
}

```


# Game Mode

GameModeBase Class  C++ AuraGameModeBase  蓝图:BP_Aura_GameMode  设置 默认Pawn 和controller

WordSetting 中设置 GameMode

BP_AuraCharacter 中设置弹簧臂相机

AuraCharacter Class 中设置角色的朝向为移动方向


ABP_Aura 动画状态机，状态切换，根据速度判断是idle 还是run 


# Enemy Interfacce

![已上传的图片](/images/20250701-Aura-UE5-leraning/ZpAlPwW8l3xDEPswRoWAacbpVzDfEcU1c8%3D.png)



```flow
flowchart LR
	A[AuraPlayerController] -->|Hover Over| B[BP_Goblin_Speas
```

