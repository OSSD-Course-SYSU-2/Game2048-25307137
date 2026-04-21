// 定义移动结果类型
interface MoveResult {
  row: number[];
  scoreAdded: number;
}

@Entry
@Component
struct Index {
  @State grid: number[][] = [
    [2, 0, 0, 0],
    [0, 4, 0, 0],
    [0, 0, 8, 0],
    [0, 0, 0, 16]
  ];
  @State score: number = 0;
  @State highScore: number = 0;
  
  // 触摸相关状态
  @State startX: number = 0;
  @State startY: number = 0;
  @State endX: number = 0;
  @State endY: number = 0;
  
  // 初始化游戏
  initGame(): void {
    this.grid = [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0]
    ];
    this.score = 0;
    this.addRandomTile();
    this.addRandomTile();
  }
  
  // 在空白位置随机生成一个新数字（90%概率为2，10%概率为4）
  addRandomTile(): void {
    const emptyCells: Array<[number, number]> = [];
    for (let i = 0; i < 4; i++) {
      for (let j = 0; j < 4; j++) {
        if (this.grid[i][j] === 0) {
          emptyCells.push([i, j]);
        }
      }
    }
    if (emptyCells.length === 0) {
      return;
    }
    const randomIndex = Math.floor(Math.random() * emptyCells.length);
    const cell = emptyCells[randomIndex];
    const row = cell[0];
    const col = cell[1];
    this.grid[row][col] = Math.random() < 0.9 ? 2 : 4;
  }
  
  // 移动并合并行（向左移动）
  moveRowLeft(row: number[]): MoveResult {
    const newRow = row.filter(cell => cell !== 0);
    let scoreAdded = 0;
    
    // 合并相邻的相同数字
    for (let i = 0; i < newRow.length - 1; i++) {
      if (newRow[i] === newRow[i + 1]) {
        newRow[i] *= 2;
        scoreAdded += newRow[i];
        newRow.splice(i + 1, 1);
      }
    }
    
    // 填充剩余位置为0
    while (newRow.length < 4) {
      newRow.push(0);
    }
    
    return { row: newRow, scoreAdded: scoreAdded };
  }
  
  // 反转行
  reverseRow(row: number[]): number[] {
    const reversed: number[] = [];
    for (let i = row.length - 1; i >= 0; i--) {
      reversed.push(row[i]);
    }
    return reversed;
  }
  
  // 转置网格
  transposeGrid(): number[][] {
    const transposed: number[][] = [];
    for (let i = 0; i < 4; i++) {
      transposed[i] = [];
      for (let j = 0; j < 4; j++) {
        transposed[i][j] = this.grid[j][i];
      }
    }
    return transposed;
  }
  
  // 向左移动
  moveLeft(): boolean {
    let moved = false;
    let totalScoreAdded = 0;
    
    for (let i = 0; i < 4; i++) {
      const result = this.moveRowLeft(this.grid[i]);
      if (JSON.stringify(result.row) !== JSON.stringify(this.grid[i])) {
        moved = true;
      }
      this.grid[i] = result.row;
      totalScoreAdded += result.scoreAdded;
    }
    
    this.score += totalScoreAdded;
    return moved;
  }
  
  // 向右移动
  moveRight(): boolean {
    let moved = false;
    let totalScoreAdded = 0;
    
    for (let i = 0; i < 4; i++) {
      const reversedRow = this.reverseRow(this.grid[i]);
      const result = this.moveRowLeft(reversedRow);
      const newRow = this.reverseRow(result.row);
      
      if (JSON.stringify(newRow) !== JSON.stringify(this.grid[i])) {
        moved = true;
      }
      this.grid[i] = newRow;
      totalScoreAdded += result.scoreAdded;
    }
    
    this.score += totalScoreAdded;
    return moved;
  }
  
  // 向上移动
  moveUp(): boolean {
    // 转置网格，向左移动，再转置回来
    const originalGrid: number[][] = [];
    for (let i = 0; i < 4; i++) {
      originalGrid[i] = [...this.grid[i]];
    }
    
    this.grid = this.transposeGrid();
    const moved = this.moveLeft();
    this.grid = this.transposeGrid();
    
    // 如果移动了，更新网格
    if (!moved) {
      this.grid = originalGrid;
    }
    
    return moved;
  }
  
  // 向下移动
  moveDown(): boolean {
    // 转置网格，向右移动，再转置回来
    const originalGrid: number[][] = [];
    for (let i = 0; i < 4; i++) {
      originalGrid[i] = [...this.grid[i]];
    }
    
    this.grid = this.transposeGrid();
    const moved = this.moveRight();
    this.grid = this.transposeGrid();
    
    // 如果移动了，更新网格
    if (!moved) {
      this.grid = originalGrid;
    }
    
    return moved;
  }
  
  // 检查游戏是否结束
  checkGameOver(): boolean {
    // 检查是否有空白单元格
    for (let i = 0; i < 4; i++) {
      for (let j = 0; j < 4; j++) {
        if (this.grid[i][j] === 0) {
          return false;
        }
      }
    }
    
    // 检查是否有相邻的相同数字
    for (let i = 0; i < 4; i++) {
      for (let j = 0; j < 4; j++) {
        const current = this.grid[i][j];
        
        // 检查右侧单元格
        if (j < 3 && current === this.grid[i][j + 1]) {
          return false;
        }
        
        // 检查下方单元格
        if (i < 3 && current === this.grid[i + 1][j]) {
          return false;
        }
      }
    }
    
    return true;
  }
  
  // 检查是否获胜（达到2048）
  checkGameWon(): boolean {
    for (let i = 0; i < 4; i++) {
      for (let j = 0; j < 4; j++) {
        if (this.grid[i][j] === 2048) {
          return true;
        }
      }
    }
    return false;
  }
  
  // 处理滑动
  handleSwipe(direction: string): void {
    let moved = false;
    
    switch (direction) {
      case 'left':
        moved = this.moveLeft();
        break;
      case 'right':
        moved = this.moveRight();
        break;
      case 'up':
        moved = this.moveUp();
        break;
      case 'down':
        moved = this.moveDown();
        break;
    }
    
    if (moved) {
      // 生成新数字
      this.addRandomTile();
      
      // 更新最高分
      if (this.score > this.highScore) {
        this.highScore = this.score;
      }
      
      // 检查游戏状态
      if (this.checkGameWon()) {
        AlertDialog.show({
          title: '恭喜！',
          message: `你达到了2048！\n得分: ${this.score}\n最高分: ${this.highScore}`,
          primaryButton: {
            value: '继续游戏',
            action: () => {
              // 允许继续游戏
            }
          },
          secondaryButton: {
            value: '重新开始',
            action: () => {
              this.initGame();
            }
          }
        });
      } else if (this.checkGameOver()) {
        AlertDialog.show({
          title: '游戏结束',
          message: `最终得分: ${this.score}\n最高分: ${this.highScore}`,
          primaryButton: {
            value: '重新开始',
            action: () => {
              this.initGame();
            }
          }
        });
      }
    }
  }
  
  getTileColor(value: number): ResourceColor {
    switch (value) {
      case 0: return '#CDC1B4';
      case 2: return '#EEE4DA';
      case 4: return '#EDE0C8';
      case 8: return '#F2B179';
      case 16: return '#F59563';
      case 32: return '#F67C5F';
      case 64: return '#F65E3B';
      case 128: return '#EDCF72';
      case 256: return '#EDCC61';
      case 512: return '#EDC850';
      case 1024: return '#EDC53F';
      case 2048: return '#EDC22E';
      default: return '#3C3A32';
    }
  }
  
  getTextColor(value: number): ResourceColor {
    return value <= 4 ? '#776E65' : '#F9F6F2';
  }
  
  getFontSize(value: number): number {
    if (value < 100) return 32;
    if (value < 1000) return 28;
    if (value < 10000) return 24;
    return 20;
  }
  
  build() {
    Column() {
      // 标题
      Text('2048')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#776E65')
        .margin({ top: 10, bottom: 5 })
      
      // 分数显示
      Row() {
        Column() {
          Text('分数')
            .fontSize(14)
            .fontColor('#EEE4DA')
            .margin({ bottom: 2 })
          Text(this.score.toString())
            .fontSize(20)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .alignItems(HorizontalAlign.Center)
        .width(70)
        .height(70)
        .backgroundColor('#BBADA0')
        .borderRadius(8)
        .padding(6)
        .margin({ right: 10 })
        
        Column() {
          Text('最高分')
            .fontSize(14)
            .fontColor('#EEE4DA')
            .margin({ bottom: 2 })
          Text(this.highScore.toString())
            .fontSize(20)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .alignItems(HorizontalAlign.Center)
        .width(70)
        .height(70)
        .backgroundColor('#BBADA0')
        .borderRadius(8)
        .padding(6)
      }
      .margin({ bottom: 8 })
      
      // 游戏说明
      Text('滑动屏幕移动方块，相同数字合并')
        .fontSize(12)
        .fontColor('#776E65')
        .margin({ bottom: 8 })
      
      // 新游戏按钮
      Button('新游戏')
        .width(100)
        .height(35)
        .backgroundColor('#8F7A66')
        .fontColor('#FFFFFF')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .borderRadius(6)
        .onClick(() => {
          this.initGame();
        })
        .margin({ bottom: 12 })
      
      // 游戏网格
      Stack() {
        // 网格背景
        Stack()
          .width(280)
          .height(280)
          .backgroundColor('#BBADA0')
          .borderRadius(10)
          .padding(6)
        
        // 游戏网格内容
        Grid() {
          ForEach(this.grid, (row: number[], rowIndex: number) => {
            ForEach(row, (value: number, colIndex: number) => {
              GridItem() {
                Stack({ alignContent: Alignment.Center }) {
                  // 方块背景
                  Stack()
                    .width('100%')
                    .height('100%')
                    .backgroundColor(this.getTileColor(value))
                    .borderRadius(6)
                  
                  // 数字显示
                  if (value !== 0) {
                    Text(value.toString())
                      .fontSize(this.getFontSize(value))
                      .fontColor(this.getTextColor(value))
                      .fontWeight(FontWeight.Bold)
                  }
                }
                .width('100%')
                .height('100%')
              }
              .backgroundColor('#BBADA0')
              .borderRadius(6)
              .padding(3)
            })
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr 1fr')
        .width(280)
        .height(280)
        .padding(6)
      }
      .margin({ bottom: 15 })
      .onTouch((event: TouchEvent) => {
        // 处理触摸事件
        if (event.type === TouchType.Down) {
          this.startX = event.touches[0].x;
          this.startY = event.touches[0].y;
        } else if (event.type === TouchType.Up) {
          this.endX = event.touches[0].x;
          this.endY = event.touches[0].y;
          
          // 计算滑动距离
          const dx = this.endX - this.startX;
          const dy = this.endY - this.startY;
          const minSwipeDistance = 30; // 最小滑动距离
          
          // 判断滑动方向
          if (Math.abs(dx) > Math.abs(dy)) {
            // 水平滑动
            if (Math.abs(dx) > minSwipeDistance) {
              if (dx > 0) {
                this.handleSwipe('right'); // 向右滑动
              } else {
                this.handleSwipe('left'); // 向左滑动
              }
            }
          } else {
            // 垂直滑动
            if (Math.abs(dy) > minSwipeDistance) {
              if (dy > 0) {
                this.handleSwipe('down'); // 向下滑动
              } else {
                this.handleSwipe('up'); // 向上滑动
              }
            }
          }
        }
      })
      
      // 操作提示
      Text('滑动屏幕或使用方向按钮')
        .fontSize(11)
        .fontColor('#776E65')
        .margin({ bottom: 8 })
      
      // 方向按钮（为没有触摸屏的设备提供备用方案）
      Column() {
        Row() {
          // 空位
          Column()
            .width(45)
            .height(45)
            .margin({ right: 8 })
          
          // 上箭头
          Button('↑')
            .width(45)
            .height(45)
            .backgroundColor('#8F7A66')
            .fontColor('#FFFFFF')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .borderRadius(6)
            .onClick(() => {
              this.handleSwipe('up');
            })
            .margin({ bottom: 8 })
          
          // 空位
          Column()
            .width(45)
            .height(45)
            .margin({ left: 8 })
        }
        
        Row() {
          // 左箭头
          Button('←')
            .width(45)
            .height(45)
            .backgroundColor('#8F7A66')
            .fontColor('#FFFFFF')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .borderRadius(6)
            .onClick(() => {
              this.handleSwipe('left');
            })
            .margin({ right: 8 })
          
          // 下箭头
          Button('↓')
            .width(45)
            .height(45)
            .backgroundColor('#8F7A66')
            .fontColor('#FFFFFF')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .borderRadius(6)
            .onClick(() => {
              this.handleSwipe('down');
            })
            .margin({ right: 8 })
          
          // 右箭头
          Button('→')
            .width('50.00vp')
            .height(45)
            .backgroundColor('#8F7A66')
            .fontColor('#FFFFFF')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .borderRadius(6)
            .onClick(() => {
              this.handleSwipe('right');
            })
            .opacity(1)
            .padding({ top: '0.00vp', right: '16.00vp', bottom: '0.00vp', left: '16.00vp' })
        }
      }
      .margin({ top: 5, bottom: 15 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAF8EF')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 10, bottom: 10 })
  }
}