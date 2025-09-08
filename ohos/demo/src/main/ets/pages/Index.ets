import demo from 'libdemo.so';
import display from '@ohos.display';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State message: string = 'Hello TGFX';

  aboutToAppear(): void {
    let displayInfo = display.getDefaultDisplaySync();
    demo.updateDensity(displayInfo.densityPixels);
  }

  build() {
    Row() {
      Column() {
        XComponent({
          id: "xcomponent",
          type: XComponentType.SURFACE,
          libraryname: "demo"
        })
      }
      .width('100%')
    }
    .height('100%')
  }
}
