package abi43_0_0.expo.modules.filesystem

import okhttp3.RequestBody
import okio.*
import java.io.IOException

@FunctionalInterface
interface RequestBodyDecorator {
  fun decorate(requestBody: RequestBody): RequestBody
}

@FunctionalInterface
interface CountingRequestListener {
  fun onProgress(bytesWritten: Long, contentLength: Long)
}

private class CountingSink(
  sink: Sink,
  private val requestBody: RequestBody,
  private val progressListener: CountingRequestListener
) : ForwardingSink(sink) {
  private var bytesWritten = 0L

  override fun write(source: Buffer, byteCount: Long) {
    super.write(source, byteCount)

    bytesWritten += byteCount
    progressListener.onProgress(bytesWritten, requestBody.contentLength())
  }
}

class CountingRequestBody(
  private val requestBody: RequestBody,
  private val progressListener: CountingRequestListener
) : RequestBody() {
  override fun contentType() = requestBody.contentType()

  @Throws(IOException::class)
  override fun contentLength() = requestBody.contentLength()

  override fun writeTo(sink: BufferedSink) {
    val countingSink = CountingSink(sink, this, progressListener)
    val bufferedSink = countingSink.buffer()
    requestBody.writeTo(bufferedSink)
    bufferedSink.flush()
  }
}
