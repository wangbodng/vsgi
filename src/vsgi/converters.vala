using GLib;

namespace VSGI {
	/**
	 * Chunks data according to RFC2616 section 3.6.1.
	 *
	 * [http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.6.1]
	 *
	 * This process has an expansion factor of ceil (log_16 (size)) + 4 due to
	 * the presence of predicted size and newlines.
	 *
	 * The process will always try to convert as much data as possible, chunking
	 * a single bloc per convert call.
	 *
	 * @since 0.2
	 */
	public class ChunkedConverter : Object, Converter {

		public ConverterResult convert (uint8[] inbuf,
				                        uint8[] outbuf,
										ConverterFlags flags,
										out size_t bytes_read,
										out size_t bytes_written) throws IOError {
			size_t required_size = 0;
			var size_buffer      = inbuf.length.to_string ("%X");

			// chunk size and newline
			required_size += size_buffer.length + "\r\n".length;

			// chunk and newline
			required_size += inbuf.length + "\r\n".length;

			// last non-zero chunk needs a zero-sized chunk
			if ((ConverterFlags.INPUT_AT_END in flags) && inbuf.length > 0) {
				required_size += 5;
			}

			if (required_size > outbuf.length)
				throw new IOError.NO_SPACE ("need %u more bytes to write the chunk", (uint) (required_size - outbuf.length));

			bytes_read    = 0;
			bytes_written = 0;

			// size
			for (int i = 0; i < size_buffer.length; i++)
				outbuf[bytes_written++] = size_buffer[i];

			// newline after the size
			outbuf[bytes_written++] = '\r';
			outbuf[bytes_written++] = '\n';

			// chunk
			for (; bytes_read < inbuf.length;)
				outbuf[bytes_written++] = inbuf[bytes_read++];

			// newline after the chunk
			outbuf[bytes_written++] = '\r';
			outbuf[bytes_written++] = '\n';

			// chunk is fully read
			assert (bytes_read == inbuf.length);
			assert (bytes_written == size_buffer.length + inbuf.length + 4);

			// write a zero-sized chunk
			if (ConverterFlags.INPUT_AT_END in flags && inbuf.length > 0) {
				outbuf[bytes_written++] = '0';
				outbuf[bytes_written++] = '\r';
				outbuf[bytes_written++] = '\n';
				outbuf[bytes_written++] = '\r';
				outbuf[bytes_written++] = '\n';
				return ConverterResult.FINISHED;
			}

			return inbuf.length == 0 ? ConverterResult.FINISHED : ConverterResult.CONVERTED;
		}

		public void reset () {
			// no internal state
		}
	}
}
